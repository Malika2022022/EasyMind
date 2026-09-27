import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReadingPage extends StatefulWidget {
  final Map<String, dynamic> book;
  final ValueNotifier<String>? contentNotifier;
  const ReadingPage({super.key, required this.book, this.contentNotifier});
  @override
  State<ReadingPage> createState() => _ReadingPageState();
}

class _ReadingPageState extends State<ReadingPage> {
  String _font = 'OpenDyslexic';
  double _fontSize = 18.0;
  double _letterSpacing = 1.0;
  double _lineHeight = 1.6;
  Color _bgColor = const Color(0xFFFFFFF0);
  Color _textColor = const Color(0xFF373737);
  Color _highlightColor = const Color(0xFFFFEB3B);
  bool _showPanel = false;
  int _panelTab = 0;
  Set<int> _highlightedWords = {};
  late String _content;

  final List<Map<String, dynamic>> _fonts = [
    {'name': 'OpenDyslexic', 'label': 'OpenDyslexic', 'isCustom': true},
    {'name': 'Roboto', 'label': 'Roboto', 'isCustom': false},
    {'name': 'Lato', 'label': 'Lato', 'isCustom': false},
    {'name': 'Merriweather', 'label': 'Merriweather', 'isCustom': false},
    {'name': 'Source Serif 4', 'label': 'Serif', 'isCustom': false},
    {'name': 'Nunito', 'label': 'Nunito', 'isCustom': false},
    {'name': 'PT Mono', 'label': 'Mono', 'isCustom': false},
  ];

  final List<Map<String, dynamic>> _bgColors = [
    {'color': const Color(0xFFFFFFF0), 'label': 'Cream'},
    {'color': const Color(0xFFFFFFFF), 'label': 'White'},
    {'color': const Color(0xFF1E1E1E), 'label': 'Dark'},
    {'color': const Color(0xFFF5E6C8), 'label': 'Sepia'},
    {'color': const Color(0xFFE8F4FD), 'label': 'Blue'},
    {'color': const Color(0xFFE8F5E9), 'label': 'Green'},
    {'color': const Color(0xFFFCE4EC), 'label': 'Pink'},
    {'color': const Color(0xFFF3E5F5), 'label': 'Lilac'},
    {'color': const Color(0xFFFFF8E1), 'label': 'Yellow'},
    {'color': const Color(0xFFE0F2F1), 'label': 'Teal'},
  ];

  final List<Map<String, dynamic>> _textColors = [
    {'color': const Color(0xFF000000), 'label': 'Black'},
    {'color': const Color(0xFF373737), 'label': 'Dark'},
    {'color': const Color(0xFF1A237E), 'label': 'Navy'},
    {'color': const Color(0xFF4A148C), 'label': 'Purple'},
    {'color': const Color(0xFF1B5E20), 'label': 'Green'},
    {'color': const Color(0xFFB71C1C), 'label': 'Red'},
    {'color': const Color(0xFF37474F), 'label': 'Slate'},
    {'color': const Color(0xFF4E342E), 'label': 'Brown'},
    {'color': const Color(0xFFFFFFFF), 'label': 'White'},
    {'color': const Color(0xFFFFFFF0), 'label': 'Cream'},
  ];

  final List<Color> _highlightColors = [
    const Color(0xFFFFEB3B),
    const Color(0xFF80FF80),
    const Color(0xFFFF80AB),
    const Color(0xFF80D8FF),
    const Color(0xFFFFB74D),
    const Color(0xFFE040FB),
    Colors.transparent,
  ];

  @override
  void initState() {
    super.initState();
    _content = widget.book['content'] as String? ?? '';
    widget.contentNotifier?.addListener(_onContentUpdate);
  }

  void _onContentUpdate() {
    if (mounted) {
      setState(() {
        _content = widget.contentNotifier!.value;
        _highlightedWords.clear();
      });
    }
  }

  @override
  void dispose() {
    widget.contentNotifier?.removeListener(_onContentUpdate);
    super.dispose();
  }

  TextStyle get _textStyle {
    if (_font == 'OpenDyslexic') {
      return TextStyle(
        fontFamily: 'OpenDyslexic',
        fontSize: _fontSize,
        letterSpacing: _letterSpacing,
        height: _lineHeight,
        color: _textColor,
      );
    }
    return GoogleFonts.getFont(
      _font,
      fontSize: _fontSize,
      letterSpacing: _letterSpacing,
      height: _lineHeight,
      color: _textColor,
    );
  }

  List<String> get _words => _content.split(RegExp(r'(\s+)'));

  @override
  Widget build(BuildContext context) {
    final words = _words;
    final isLoading = _content == 'Loading...';

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.book['title'] as String? ?? '',
          style: TextStyle(
            color: _textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.text_fields, color: _textColor),
            onPressed: () => setState(() => _showPanel = !_showPanel),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          color: Color(0xFFA63D30),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Loading book...",
                          style: TextStyle(color: _textColor),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _content.split('\n\n').map((paragraph) {
                      if (paragraph.trim().isEmpty) return const SizedBox(height: 16);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Wrap(
                          children: paragraph.split(' ').asMap().entries.map((entry) {
                            final wordIndex = entry.key;
                            final word = entry.value;
                            final globalIndex = _content.indexOf(paragraph) + wordIndex;
                            final isHighlighted = _highlightedWords.contains(globalIndex);
                            return GestureDetector(
                              onTap: () => setState(() {
                                isHighlighted 
                                ? _highlightedWords.remove(globalIndex)
                                : _highlightedWords.add(globalIndex);
                                }),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isHighlighted ? _highlightColor : Colors.transparent,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text('$word ', style: _textStyle),
                                ),
                            );
                         }).toList(),
                        ),
                      );
                    }).toList(),
                  ),
                ),
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
                    color: Colors.black.withValues(alpha: 0.2),
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
                      _buildPanelTab("Highlight", 3),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 1),
                  if (_panelTab == 0) _buildFontPanel(),
                  if (_panelTab == 1) _buildColorPanel(),
                  if (_panelTab == 2) _buildSpacingPanel(),
                  if (_panelTab == 3) _buildHighlightPanel(),
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
                color: isSelected
                    ? const Color(0xFFA63D30)
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
                  isSelected ? const Color(0xFFA63D30) : Colors.white54,
              fontWeight:
                  isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 12,
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
          const Text("Font",
              style: TextStyle(color: Colors.white54, fontSize: 12)),
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
                  onTap: () =>
                      setState(() => _font = font['name'] as String),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFA63D30)
                          : Colors.white12,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Text(
                      font['label'] as String,
                      style: TextStyle(
                        fontFamily: font['isCustom'] == true
                            ? font['name'] as String
                            : null,
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
              const Text("Size",
                  style: TextStyle(color: Colors.white54, fontSize: 12)),
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
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 12)),
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
          const Text("Background",
              style: TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 10),
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _bgColors.length,
              itemBuilder: (context, index) {
                final item = _bgColors[index];
                final color = item['color'] as Color;
                final isSelected = _bgColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _bgColor = color),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFA63D30)
                            : Colors.white24,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check,
                            size: 16, color: Color(0xFFA63D30))
                        : null,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          const Text("Text Color",
              style: TextStyle(color: Colors.white54, fontSize: 12)),
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
                        color: isSelected
                            ? const Color(0xFFA63D30)
                            : Colors.white24,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child: isSelected
                        ? Icon(Icons.check,
                            size: 16,
                            color: color == Colors.white ||
                                    color == const Color(0xFFFFFFF0)
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
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 12)),
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
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightPanel() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tap any word to highlight it",
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 12),
          const Text(
            "Highlight Color",
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ..._highlightColors.map((color) {
                final isSelected = _highlightColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _highlightColor = color),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color == Colors.transparent
                          ? Colors.white12
                          : color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFA63D30)
                            : Colors.white24,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child: color == Colors.transparent
                        ? const Icon(Icons.clear,
                            size: 16, color: Colors.white54)
                        : isSelected
                            ? const Icon(Icons.check,
                                size: 16, color: Colors.black54)
                            : null,
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => setState(() => _highlightedWords.clear()),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "Clear all highlights",
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}