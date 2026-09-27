import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';

class ListeningScreen extends StatefulWidget {
  const ListeningScreen({Key? key}) : super(key: key);

  @override
  State<ListeningScreen> createState() => _ListeningScreenState();
}

class _ListeningScreenState extends State<ListeningScreen> {
  final AudioPlayer _player = AudioPlayer();
  List<Map<String, String>> _audioFiles = [];
  int _currentIndex = -1;
  double _speed = 1.0;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;
  bool _isPicking = false;
  String _transcription = '';
  @override
  void initState() {
    super.initState();
    _player.positionStream.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _player.durationStream.listen((d) {
      if (mounted) setState(() => _duration = d ?? Duration.zero);
    });
    _player.playerStateStream.listen((state) {
      if (mounted) setState(() => _isPlaying = state.playing);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
  Future<void> _addTranscription() async {
  final controller = TextEditingController(text: _transcription);
  final result = await showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFFFFFFF0),
      title: const Text('Audio Text',
          style: TextStyle(fontWeight: FontWeight.w600)),
      content: TextField(
        controller: controller,
        maxLines: 6,
        decoration: const InputDecoration(
          hintText: 'Paste or type the audio text here...',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel',
              style: TextStyle(color: Color(0xFF373737))),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, controller.text.trim()),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFA63D30),
          ),
          child: const Text('Save', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
  if (result != null) {
    setState(() => _transcription = result);
  }
  }
  Future<void> _addAudio() async {
    if (_isPicking) return;
    setState(() => _isPicking = true);
    try {
      await FilePicker.platform.clearTemporaryFiles();
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      if (result != null && mounted) {
        final file = result.files.single;
        final ext = file.extension?.toLowerCase() ?? '';
        if (['mp3', 'wav', 'm4a', 'aac', 'ogg', 'flac', 'mp4'].contains(ext)) {
          setState(() {
            _audioFiles.add({
              'title': file.name.replaceAll(RegExp(r'\.[^.]+$'), ''),
              'path': file.path ?? '',
            });
          });
          // Auto play the added file
          await _playAudio(_audioFiles.length - 1);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Please select an audio file (mp3, wav, m4a, etc.)")),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('File picker error: $e');
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  Future<void> _playAudio(int index) async {
    if (_audioFiles[index]['path']!.isEmpty) return;
    setState(() => _currentIndex = index);
    try {
      await _player.setFilePath(_audioFiles[index]['path']!);
      await _player.setSpeed(_speed);
      await _player.play();
    } catch (e) {
      debugPrint('Play error: $e');
    }
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> _setSpeed(double speed) async {
    setState(() => _speed = speed);
    await _player.setSpeed(speed);
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFF0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF373737)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Listening',
          style: TextStyle(
            color: Color(0xFF373737),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Now playing card
                  if (_currentIndex >= 0)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF373737),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFA63D30),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.music_note,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Now Playing',
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      _audioFiles[_currentIndex]['title']!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Progress bar
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: const Color(0xFFA63D30),
                              inactiveTrackColor: Colors.white24,
                              thumbColor: const Color(0xFFA63D30),
                              trackHeight: 4,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6,
                              ),
                            ),
                            child: Slider(
                              value: _position.inSeconds.toDouble(),
                              max: _duration.inSeconds.toDouble().clamp(1, double.infinity),
                              onChanged: (v) async {
                                await _player.seek(Duration(seconds: v.toInt()));
                              },
                            ),
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(_position),
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                _formatDuration(_duration),
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Controls
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.replay_10,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                onPressed: () async {
                                  final newPos = _position - const Duration(seconds: 10);
                                  await _player.seek(
                                    newPos < Duration.zero ? Duration.zero : newPos,
                                  );
                                },
                              ),
                              const SizedBox(width: 16),
                              GestureDetector(
                                onTap: _togglePlay,
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFA63D30),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _isPlaying ? Icons.pause : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              IconButton(
                                icon: const Icon(
                                  Icons.forward_10,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                onPressed: () async {
                                  final newPos = _position + const Duration(seconds: 10);
                                  await _player.seek(
                                    newPos > _duration ? _duration : newPos,
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  if (_currentIndex >= 0) const SizedBox(height: 20),

                  // Speed control
                  if (_currentIndex >= 0)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF373737),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Speed',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((s) {
                              final isSelected = _speed == s;
                              return GestureDetector(
                                onTap: () => _setSpeed(s),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFA63D30)
                                        : Colors.white12,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${s}x',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    
if (_currentIndex >= 0) const SizedBox(height: 20), 
  Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF373737),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Audio Text',
                style: TextStyle(color: Colors.white54, fontSize: 12)),
            GestureDetector(
              onTap: _addTranscription,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFA63D30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Edit',
                    style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          _transcription.isEmpty
              ? 'Tap Edit to add audio text'
              : _transcription,
          style: TextStyle(
            color: _transcription.isEmpty
                ? Colors.white24
                : Colors.white,
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ],
    ),
  ),

if (_currentIndex >= 0) const SizedBox(height: 20), 
                  if (_currentIndex >= 0) const SizedBox(height: 20),
                  
                  // Playlist
                  const Text(
                    'My Audio',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Color(0xFF373737),
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (_audioFiles.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'No audio files yet.\nTap the button below to add.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ...List.generate(_audioFiles.length, (index) {
                      final isCurrentlyPlaying =
                          _currentIndex == index && _isPlaying;
                      return GestureDetector(
                        onTap: () => _playAudio(index),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _currentIndex == index
                                ? const Color(0xFFA63D30)
                                : const Color(0xFF373737),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isCurrentlyPlaying
                                    ? Icons.volume_up
                                    : Icons.music_note,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _audioFiles[index]['title']!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(
                                Icons.play_arrow,
                                color: Colors.white54,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Add audio button
          Padding(
            padding: const EdgeInsets.all(20),
            child: GestureDetector(
              onTap: _isPicking ? null : _addAudio,
              child: Container(
                height: 56,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _isPicking
                      ? Colors.grey
                      : const Color(0xFFA63D30),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      _isPicking ? 'Loading...' : 'Add Audio File',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}