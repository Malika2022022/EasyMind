import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http_parser/http_parser.dart';


class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerPage({super.key, required this.videoUrl});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late YoutubePlayerController _controller;
  Timer? _captionTimer;
  double _currentSpeed = 1.0;
  String _currentFont = 'Arial';
  double _spacing = 1.0;
  List<_Caption>? _subtitles;
  String _currentCaption = "";
  String _debugError = "initializing...";
  bool _isRecording = false;
  bool _isAnalyzing = false;
  String _feedback = "";
  final AudioRecorder _recorder = AudioRecorder();
  String? _recordingPath;
  static const String kOpenAiKey = 'My_Api';

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    _controller = YoutubePlayerController(
      initialVideoId: videoId ?? "",
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: false,
      ),
    );
    _captionTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _videoListener();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSubtitles();
    });
  }

  void _videoListener() {
    if (_subtitles == null || _subtitles!.isEmpty) return;
    final currentPos = _controller.value.position;
    final matching = _subtitles!.where((caption) =>
        currentPos >= caption.offset &&
        currentPos <= (caption.offset + caption.duration));
    if (matching.isNotEmpty) {
      final text = matching.first.text;
      if (_currentCaption != text) setState(() => _currentCaption = text);
    } else {
      if (_currentCaption.isNotEmpty) setState(() => _currentCaption = "");
    }
  }
  static const String _searchApiKey = 'LWnavcnqxK1PkZgNXE9wkznm';

Future<void> _loadSubtitles() async {
  final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
  if (videoId == null) { _updateStatus("Bad URL"); return; }
  _updateStatus("Loading captions...");

  try {
    final response = await http.get(
      Uri.parse(
        'https://www.searchapi.io/api/v1/search'
        '?engine=youtube_transcripts'
        '&video_id=$videoId'
        '&lang=en'
        '&api_key=$_searchApiKey'
      ),
    ).timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List subtitles = data['transcripts'] ?? [];

      if (subtitles.isEmpty) {
        _updateStatus("No captions found");
        return;
      }

      final captions = subtitles.map((s) => _Caption(
        Duration(milliseconds: ((s['start'] as double) * 1000).round()),
        Duration(milliseconds: ((s['duration'] as double) * 1000).round()),
        s['text'] as String,
      )).toList();

      if (mounted) {
        setState(() {
          _subtitles = captions;
          _debugError = "DONE: ${captions.length} captions";
        });
      }
    } else {
      _updateStatus("Failed: ${response.statusCode}");
    }
  } on TimeoutException {
    _updateStatus("TIMEOUT");
  } catch (e) {
    _updateStatus("Error: $e");
  }
}

  Future<void> _startShadowing() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      setState(() => _feedback = "Microphone permission denied.");
      return;
    }
    final dir = await getTemporaryDirectory();
    _recordingPath = '${dir.path}/shadowing.m4a';
    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: _recordingPath!,
    );
    _controller.seekTo(Duration.zero);
    _controller.play();
    setState(() {
      _isRecording = true;
      _feedback = "";
    });
  }

  Future<void> _stopShadowing() async {
    await _recorder.stop();
    _controller.pause();
    setState(() {
      _isRecording = false;
      _isAnalyzing = true;
      _feedback = "Analyzing your pronunciation...";
    });
    await _analyzeShadowing();
  }
  Future<void> _analyzeShadowing() async {
  try {
    if (_recordingPath == null) return;
    final audioFile = File(_recordingPath!);
    if (!await audioFile.exists()) {
      setState(() {
        _isAnalyzing = false;
        _feedback = "Recording not found.";
      });
      return;
    }
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.openai.com/v1/audio/transcriptions'),
    );
    request.headers['Authorization'] = 'Bearer $kOpenAiKey';
    request.fields['model'] = 'whisper-1';
    request.fields['language'] = 'en';
    request.fields['response_format'] = 'text';
    request.files.add(await http.MultipartFile.fromPath(
      'file',
      _recordingPath!,
      contentType: MediaType('audio', 'm4a'),
    ));

    final streamed = await request.send();
    final transcribeResponse = await http.Response.fromStream(streamed);

    if (transcribeResponse.statusCode != 200) {
      setState(() {
        _isAnalyzing = false;
        _feedback = "Transcription failed. Try again.";
      });
      return;
    }

    final recognizedText = transcribeResponse.body.trim();
    final subtitleText = _currentCaption.isNotEmpty 
        ? _currentCaption 
        : (_subtitles?.map((c) => c.text).join(' ') ?? '');
    final gptResponse = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $kOpenAiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'max_tokens': 200,
        'messages': [
          {
            'role': 'user',
            'content': '''You are a friendly English pronunciation coach helping a dyslexic learner.
Original subtitle: "$subtitleText"
Student said: "$recognizedText"
Give SHORT friendly feedback (3-4 sentences). Cover what was correct, what needs improvement, and one tip. Be encouraging.'''
          }
        ],
      }),
    ).timeout(const Duration(seconds: 30));

    if (gptResponse.statusCode == 200) {
      final data = jsonDecode(gptResponse.body);
      final feedback = data['choices'][0]['message']['content'].trim();
      setState(() {
        _feedback = feedback;
        _isAnalyzing = false;
      });
    } else {
      setState(() {
        _feedback = "Analysis failed. Try again.";
        _isAnalyzing = false;
      });
    }
  } catch (e) {
    setState(() {
      _feedback = "Error: $e";
      _isAnalyzing = false;
    });
  }
}
  void _updateStatus(String msg) {
    if (mounted) setState(() => _debugError = msg);
    debugPrint("SUBTITLE_STATUS: $msg");
  }

  void _printError(String label, Object e, StackTrace stack) {
    _updateStatus("$label: $e");
    debugPrint("ERROR: $e\n$stack");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFF0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  YoutubePlayer(
                    controller: _controller,
                    showVideoProgressIndicator: true,
                  ),
                  Positioned(
                    bottom: 20, left: 0, right: 0,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          _currentCaption,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: _currentFont,
                            letterSpacing: _spacing,
                            fontSize: 20,
                            color: const Color(0xFFFFFFF0),
                            backgroundColor: _currentCaption.isEmpty
                                ? Colors.transparent
                                : const Color(0xFF373737).withOpacity(0.8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 5, left: 5,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SelectableText(
                  'Status: $_debugError',
                  style: const TextStyle(color: Colors.red, fontSize: 10),
                ),
              ),
              _buildSpeedSlider(),
              _buildSectionTitle("Font Style"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStyleButton("OpenDyslexic"),
                  _buildStyleButton("Arial"),
                  _buildStyleButton("Sample Text"),
                ],
              ),
              const SizedBox(height: 23),
              _buildSectionTitle("Letter Spacing"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSpacingButton("Default", 1.0),
                  _buildSpacingButton("Wide", 3.0),
                  _buildSpacingButton("Extra Wide", 6.0),
                ],
              ),
              const Divider(color: Color(0xFF373737), thickness: 1, height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                child: ElevatedButton(
                  onPressed: _isAnalyzing
                      ? null
                      : (_isRecording ? _stopShadowing : _startShadowing),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRecording
                        ? Colors.red
                        : const Color(0xFFA63D30),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    _isAnalyzing
                        ? "Analyzing..."
                        : (_isRecording ? "STOP SHADOWING" : "START SHADOWING"),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (_feedback.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF373737),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _feedback,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _captionTimer?.cancel();
    _controller.dispose();
    _recorder.dispose();
    super.dispose();
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 26),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF373737)),
      ),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
      ),
    );
  }

  Widget _buildStyleButton(String text) {
    bool isSelected = _currentFont == text;
    return GestureDetector(
      onTap: () => setState(() => _currentFont = text),
      child: Container(
        width: 100, height: 71,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFA63D30)
              : const Color(0xFF373737),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildSpacingButton(String text, double value) {
    bool isSelected = _spacing == value;
    return GestureDetector(
      onTap: () => setState(() => _spacing = value),
      child: Container(
        width: 100, height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFA63D30)
              : const Color(0xFF373737),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Color(0xFF373737)),
        ),
      ),
    );
  }

  Widget _buildSpeedSlider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Image.asset('lib/images/Symbol - Min.png', width: 30, height: 30),
          Expanded(
            child: Slider(
              value: _currentSpeed,
              min: 0.5,
              max: 2.0,
              divisions: 6,
              activeColor: const Color(0xFFA63D30),
              onChanged: (double value) {
                setState(() {
                  _currentSpeed = value;
                  _controller.setPlaybackRate(value);
                });
              },
            ),
          ),
          Image.asset('lib/images/Symbol - Max.png', width: 30, height: 30),
        ],
      ),
    );
  }
}

class _Caption {
  final Duration offset, duration;
  final String text;
  _Caption(this.offset, this.duration, this.text);
}