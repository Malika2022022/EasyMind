import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
class DyslexiaWritingApp extends StatelessWidget {
  const DyslexiaWritingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const WritingScreen();
  }
}

class WritingScreen extends StatefulWidget {
  const WritingScreen({Key? key}) : super(key: key);

  @override
  State<WritingScreen> createState() => _WritingScreenState();
}

class _WritingScreenState extends State<WritingScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Color _backgroundColor = const Color(0xFFFFFFF0);
  Color _textColor = const Color(0xFF373737);
  double _fontSize = 18.0;
  double _letterSpacing = 1.0;
  double _lineHeight = 1.8;
  String _font = 'Arial';
  List<String> _predictions = [];
  bool _showPanel = false;
  int _panelTab = 0;

  final List<String> wordDictionary = [
    'about', 'after', 'all', 'also', 'and', 'another', 'any', 'are',
    'around', 'as', 'ask', 'at', 'back', 'be', 'because', 'before',
    'begin', 'being', 'best', 'between', 'big', 'both', 'but', 'by',
    'call', 'came', 'can', 'come', 'could', 'day', 'did', 'do', 'does',
    'doing', 'done', 'down', 'during', 'each', 'early', 'end', 'even',
    'every', 'face', 'fact', 'feel', 'few', 'find', 'first', 'for',
    'found', 'from', 'full', 'get', 'give', 'go', 'good', 'got', 'great',
    'had', 'has', 'have', 'he', 'head', 'hear', 'help', 'here', 'high',
    'him', 'his', 'home', 'how', 'idea', 'if', 'important', 'in', 'into',
    'is', 'it', 'its', 'just', 'keep', 'kind', 'know', 'large', 'last',
    'learn', 'leave', 'left', 'less', 'life', 'like', 'little', 'live',
    'long', 'look', 'lot', 'love', 'made', 'make', 'man', 'many', 'may',
    'me', 'mean', 'meet', 'might', 'mind', 'more', 'most', 'move', 'much',
    'must', 'my', 'name', 'need', 'never', 'new', 'next', 'no', 'not',
    'now', 'of', 'off', 'often', 'old', 'on', 'one', 'only', 'open',
    'or', 'other', 'out', 'own', 'part', 'people', 'place', 'play',
    'point', 'possible', 'problem', 'put', 'question', 'quickly', 'quite',
    'rather', 'reach', 'read', 'ready', 'real', 'really', 'reason',
    'remember', 'right', 'run', 'said', 'same', 'school', 'see', 'seem',
    'self', 'send', 'sense', 'set', 'several', 'she', 'should', 'show',
    'since', 'small', 'some', 'something', 'sometimes', 'soon', 'sound',
    'speak', 'special', 'stand', 'start', 'state', 'stay', 'still',
    'stop', 'story', 'strong', 'student', 'study', 'such', 'sure',
    'take', 'talk', 'tell', 'than', 'thank', 'that', 'the', 'their',
    'them', 'then', 'there', 'these', 'they', 'thing', 'think', 'this',
    'thought', 'three', 'through', 'time', 'to', 'today', 'together',
    'too', 'took', 'top', 'toward', 'true', 'try', 'turn', 'two',
    'under', 'understand', 'until', 'up', 'use', 'usually', 'very',
    'want', 'was', 'watch', 'water', 'way', 'we', 'week', 'well',
    'went', 'were', 'what', 'when', 'where', 'which', 'while', 'who',
    'why', 'will', 'with', 'without', 'word', 'work', 'world', 'would',
    'write', 'year', 'yes', 'yet', 'you', 'your',
  ];

  final List<Map<String, String>> spellingPairs = [
    {'letter1': 'd', 'letter2': 'b'},
    {'letter1': 'p', 'letter2': 'q'},
    {'letter1': 'n', 'letter2': 'u'},
    {'letter1': 'M', 'letter2': 'W'},
  ];

  final List<Map<String, dynamic>> _bgColors = [
    {'color': const Color(0xFFFFFFF0), 'label': 'Cream'},
    {'color': const Color(0xFFFFFFFF), 'label': 'White'},
    {'color': const Color(0xFF1E1E1E), 'label': 'Dark'},
    {'color': const Color(0xFFF5E6C8), 'label': 'Sepia'},
    {'color': const Color(0xFFE8F4FD), 'label': 'Blue'},
    {'color': const Color(0xFFE8F5E9), 'label': 'Green'},
    {'color': const Color(0xFFFCE4EC), 'label': 'Pink'},
    {'color': const Color(0xFFFFF8E1), 'label': 'Yellow'},
  ];

  final List<Map<String, dynamic>> _textColors = [
    {'color': const Color(0xFF373737), 'label': 'Dark'},
    {'color': const Color(0xFF000000), 'label': 'Black'},
    {'color': const Color(0xFF1A237E), 'label': 'Navy'},
    {'color': const Color(0xFFFFFFFF), 'label': 'White'},
    {'color': const Color(0xFFFFFFF0), 'label': 'Cream'},
  ];

  final List<Map<String, dynamic>> _fonts = [
    {'name': 'OpenDyslexic', 'label': 'OpenDyslexic'},
    {'name': 'Arial', 'label': 'Arial'},
    {'name': 'Georgia', 'label': 'Georgia'},
    {'name': 'Verdana', 'label': 'Verdana'},
  ];

  @override
  void initState() {
    super.initState();
    _textController.addListener(_updatePredictions);
  }

  String _getLastWord(String text) {
    final words = text.split(RegExp(r'\s+'));
    return words.last.toLowerCase();
  }

  void _updatePredictions() {
    final lastWord = _getLastWord(_textController.text);
    if (lastWord.isEmpty) {
      setState(() => _predictions = []);
      return;
    }
    final filtered = wordDictionary
        .where((w) => w.startsWith(lastWord) && w != lastWord)
        .take(5)
        .toList();
    setState(() => _predictions = filtered);
  }

  void _insertWord(String word) {
    final text = _textController.text;
    final lastWord = _getLastWord(text);
    final idx = text.lastIndexOf(lastWord);
    final newText = text.substring(0, idx) + word + ' ';
    _textController.text = newText;
    _textController.selection =
        TextSelection.fromPosition(TextPosition(offset: newText.length));
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wordCount = _textController.text.isEmpty
        ? 0
        : _textController.text.trim().split(RegExp(r'\s+')).length;

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
          'Writing Helper',
          style: TextStyle(
            color: Color(0xFF373737),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_textController.text.isNotEmpty)
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.share, color: Color(0xFF373737)),
              onPressed: () async {
                final box = context.findRenderObject() as RenderBox?;
                await Share.share(
                  _textController.text,
                  sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
                );
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.text_fields, color: Color(0xFF373737)),
            onPressed: () => setState(() => _showPanel = !_showPanel),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_predictions.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Word suggestions',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _predictions.map((word) =>
                              GestureDetector(
                                onTap: () => _insertWord(word),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF373737),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    word,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ).toList(),
                          ),
                        ],
                      ),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      color: _backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF373737)),
                    ),
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      maxLines: null,
                      minLines: 12,
                      decoration: const InputDecoration(
                        hintText: 'Start writing here...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                      style: TextStyle(
                        fontFamily: _font == 'OpenDyslexic' ? 'OpenDyslexic' : null,
                        fontSize: _fontSize,
                        letterSpacing: _letterSpacing,
                        height: _lineHeight,
                        color: _textColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  Text(
                    'Words: $wordCount  ·  Characters: ${_textController.text.length}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'Commonly confused letters',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xFF373737),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF373737),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: spellingPairs.map((pair) =>
                        Column(
                          children: [
                            Text(
                              pair['letter1']!,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'OpenDyslexic',
                              ),
                            ),
                            const Text('/', style: TextStyle(color: Colors.white54)),
                            Transform(
                              transform: Matrix4.identity()..scale(-1.0, 1.0),
                              alignment: Alignment.center,
                              child: Text(
                                pair['letter2']!,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFA63D30),
                                  fontFamily: 'OpenDyslexic',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).toList(),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          ListenableBuilder(
            listenable: _focusNode,
            builder: (context, _) {
              if (!_focusNode.hasFocus) return const SizedBox.shrink();
              return Container(
                color: const Color(0xFFF5F5F5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _focusNode.unfocus(),
                      child: const Text(
                        "Done",
                        style: TextStyle(
                        color: Color(0xFFA63D30),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          if (_showPanel)
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF373737),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      _buildPanelTab("Font", 0),
                      _buildPanelTab("Colors", 1),
                      _buildPanelTab("Spacing", 2),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 1),
                  if (_panelTab == 0) _buildFontPanel(),
                  if (_panelTab == 1) _buildColorPanel(),
                  if (_panelTab == 2) _buildSpacingPanel(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPanelTab(String label, int index) {
    final isSelected = _panelTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _panelTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? const Color(0xFFA63D30) : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? const Color(0xFFA63D30) : Colors.white54,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFontPanel() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Font", style: TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 10),
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _fonts.length,
              itemBuilder: (context, index) {
                final font = _fonts[index];
                final isSelected = _font == font['name'];
                return GestureDetector(
                  onTap: () => setState(() => _font = font['name'] as String),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFA63D30) : Colors.white12,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Text(
                      font['label'] as String,
                      style: TextStyle(
                        fontFamily: font['name'] == 'OpenDyslexic' ? 'OpenDyslexic' : null,
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Text("Size", style: TextStyle(color: Colors.white54, fontSize: 12)),
              Expanded(
                child: Slider(
                  value: _fontSize,
                  min: 12,
                  max: 32,
                  divisions: 10,
                  activeColor: const Color(0xFFA63D30),
                  inactiveColor: Colors.white24,
                  onChanged: (v) => setState(() => _fontSize = v),
                ),
              ),
              Text("${_fontSize.toInt()}px",
                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorPanel() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Background", style: TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 10),
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _bgColors.length,
              itemBuilder: (context, index) {
                final item = _bgColors[index];
                final color = item['color'] as Color;
                final isSelected = _backgroundColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _backgroundColor = color),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? const Color(0xFFA63D30) : Colors.white24,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 16, color: Color(0xFFA63D30))
                        : null,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          const Text("Text Color", style: TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 10),
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _textColors.length,
              itemBuilder: (context, index) {
                final item = _textColors[index];
                final color = item['color'] as Color;
                final isSelected = _textColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _textColor = color),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? const Color(0xFFA63D30) : Colors.white24,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child: isSelected
                        ? Icon(Icons.check,
                            size: 16,
                            color: color == Colors.white || color == const Color(0xFFFFFFF0)
                                ? Colors.black
                                : Colors.white)
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpacingPanel() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Text("Letter Spacing",
                  style: TextStyle(color: Colors.white54, fontSize: 12)),
              Expanded(
                child: Slider(
                  value: _letterSpacing,
                  min: 0,
                  max: 8,
                  divisions: 8,
                  activeColor: const Color(0xFFA63D30),
                  inactiveColor: Colors.white24,
                  onChanged: (v) => setState(() => _letterSpacing = v),
                ),
              ),
              Text("${_letterSpacing.toInt()}",
                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
          Row(
            children: [
              const Text("Line Height  ",
                  style: TextStyle(color: Colors.white54, fontSize: 12)),
              Expanded(
                child: Slider(
                  value: _lineHeight,
                  min: 1.0,
                  max: 3.0,
                  divisions: 8,
                  activeColor: const Color(0xFFA63D30),
                  inactiveColor: Colors.white24,
                  onChanged: (v) => setState(() => _lineHeight = v),
                ),
              ),
              Text(_lineHeight.toStringAsFixed(1),
                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}