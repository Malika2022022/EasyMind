import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:testdrive/reading.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  bool _isLoading = false;

  List<Map<String, dynamic>> myBooks = [
    {
      "title": "Sherlock Holmes",
      "author": "Arthur Conan Doyle",
      "content": "Click to download the full classic...",
      "id": "1661",
      "type": "classic",
      "progress": 0.0,
      "cover": "https://www.gutenberg.org/cache/epub/1661/pg1661.cover.medium.jpg",
    },
    {
      "title": "Alice in Wonderland",
      "author": "Lewis Carroll",
      "content": "Click to download the full classic...",
      "id": "11",
      "type": "classic",
      "progress": 0.0,
      "cover": "https://www.gutenberg.org/cache/epub/11/pg11.cover.medium.jpg",
    },
    {
      "title": "Pride and Prejudice",
      "author": "Jane Austen",
      "content": "Click to download the full classic...",
      "id": "1342",
      "type": "classic",
      "progress": 0.0,
      "cover": "https://www.gutenberg.org/cache/epub/1342/pg1342.cover.medium.jpg",
    },
  ];

  Future<void> _downloadBook(int index) async {
    if (!mounted) return;
    final notifier = ValueNotifier<String>('Loading...');
    _openBook(myBooks[index], notifier: notifier);
    try {
      final bookId = myBooks[index]['id'];
      final response = await http.get(
        Uri.parse('https://gutendex.com/books/$bookId'),
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String? textUrl =
            data['formats']['text/plain; charset=us-ascii'] ??
            data['formats']['text/plain; charset=utf-8'];
        if (textUrl != null) {
          final textResponse = await http.get(Uri.parse(textUrl));
          if (!mounted) return;
          if (textResponse.statusCode == 200) {
            final cleaned = _cleanGutenberg(textResponse.body);
            notifier.value = cleaned.substring(0, cleaned.length.clamp(0, 15000)) +'\n\n[Loading more...]';
            await Future.delayed(const Duration(milliseconds: 500));
            setState(() => myBooks[index]['content'] = cleaned);
            notifier.value = cleaned;
          }
        }
      }
    } catch (e) {
      if (!mounted) return;
      notifier.value = 'Error loading book: $e';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  String _cleanGutenberg(String text) {
    final start = text.indexOf("*** START OF");
    if (start != -1) {
      final actualStart = text.indexOf("\n", start + 20);
      text = text.substring(actualStart).trim();
    }
    text = text
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .replaceAll(RegExp(r'(?<!\n)\n(?!\n)'), ' ');
    return text;
  }

  Future<void> _uploadLocalFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
      withData: true,
    );
    if (result != null && mounted) {
      final bytes = result.files.single.bytes;
      final content = bytes != null
          ? String.fromCharCodes(bytes)
          : "Could not read file";
      setState(() {
        myBooks.add({
          "title": result.files.single.name.replaceAll('.txt', ''),
          "author": "Local file",
          "content": content,
          "type": "upload",
          "progress": 0.0,
          "cover": "",
        });
      });
    }
  }
  Future<void> _downloadFromUrl() async {
  final TextEditingController urlController = TextEditingController();
  final TextEditingController titleController = TextEditingController();

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFFFFFFF0),
      title: const Text("Download from URL"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              hintText: "Book title",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: urlController,
            decoration: const InputDecoration(
              hintText: "Paste any link (PDF or webpage)",
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFA63D30),
          ),
          onPressed: () async {
            Navigator.pop(context);
            if (urlController.text.isEmpty) return;
            final notifier = ValueNotifier<String>('Loading...');
            final title = titleController.text.isNotEmpty
            ? titleController.text
            : 'Downloaded Book';
            setState(() {
              myBooks.add({
                "title": title,
                "author": "Downloaded",
                "content": "Loading...",
                "type": "classic",
                "progress": 0.0,
                "cover": "",
              });
            });
            _openBook(myBooks.last, notifier: notifier);
            try {
              final response = await http.get(
                Uri.parse(urlController.text),
                headers: {'User-Agent': 'Mozilla/5.0'},
              );
              if (response.statusCode == 200) {
                String content = '';
                final url = urlController.text.toLowerCase();
                final isPdf = url.endsWith('.pdf') || response.headers['content-type']?.contains('pdf') == true;
                if (isPdf) {
                  try {
                    final PdfDocument document = PdfDocument(inputBytes: response.bodyBytes);
                    final PdfTextExtractor extractor = PdfTextExtractor(document);
                    content = extractor.extractText();
                    document.dispose();
                    final lines = content.split('\n');
                    final avgLineLength = lines.isEmpty ? 0 : 
                    lines.map((l) => l.length).reduce((a, b) => a + b) / lines.length;
                    if (avgLineLength < 20) {
                      notifier.value = 'This PDF has a complex layout that cannot be read properly.\n\n'
                      'Try finding a .txt or .epub version of this book instead.\n\n'
                      'Good sources:\n'
                      '• gutenberg.org\n'
                      '• standardebooks.org\n'
                      '• archive.org';
                      setState(() => myBooks.last['content'] = notifier.value);
                      return;
                    }
                  } catch (e) {
                    notifier.value = 'Could not read PDF: $e';
                    return;
                  }
                }else {
                  content = response.body.isNotEmpty
                  ? response.body
                  : String.fromCharCodes(response.bodyBytes);
                }
                content = content
                  .replaceAll(RegExp(r'\n{3,}'), '\n\n')
                  .replaceAll(RegExp(r' {2,}'), ' ')
                  .trim();
                notifier.value = content.substring(0, content.length.clamp(0, 15000)) +'\n\n[Loading more...]';
                await Future.delayed(const Duration(milliseconds: 500));
                setState(() => myBooks.last['content'] = content);
                notifier.value = content.isEmpty ? 'Could not extract text' : content;
                } else {
                  notifier.value = 'Failed to load. Status: ${response.statusCode}';
                }
             } catch (e) {
              notifier.value = 'Error: $e';
            }
          },
          child: const Text("Download", style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}
  void _openBook(Map<String, dynamic> book, {ValueNotifier<String>? notifier}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReadingPage(
          book: book,
          contentNotifier: notifier,
        ),
      ),
    );
  }

  Future<void> _addBook() async {
    final TextEditingController searchController = TextEditingController();
    List<dynamic> results = [];
    bool isSearching = false;

    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFFFFF0),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          Future<void> search(String query) async {
            if (query.isEmpty) return;
            setModalState(() => isSearching = true);
            try {
              final response = await http.get(
                Uri.parse(
                  'https://openlibrary.org/search.json?q=${Uri.encodeComponent(query)}&limit=20',
                ),
              );
              if (response.statusCode == 200) {
                final data = jsonDecode(response.body);
                setModalState(() {
                  results = data['docs'] ?? [];
                  isSearching = false;
                });
              } else {
                setModalState(() => isSearching = false);
              }
            } catch (e) {
              setModalState(() => isSearching = false);
            }
          }

          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Add Book",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: "Search by title or author...",
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search, color: Color(0xFFA63D30)),
                      onPressed: () => search(searchController.text),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF373737)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFA63D30)),
                    ),
                  ),
                  onSubmitted: (val) => search(val),
                ),
                const SizedBox(height: 16),
                if (isSearching)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(color: Color(0xFFA63D30)),
                  )
                else if (results.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "Type a title or author and press search",
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  SizedBox(
                    height: 300,
                    child: ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final book = results[index];
                        final title = book['title'] ?? 'Unknown';
                        final authors =
                            (book['author_name'] as List?)?.join(', ') ??
                                'Unknown author';
                        final coverId = book['cover_i']?.toString() ?? '';
                        final cover = coverId.isNotEmpty
                            ? 'https://covers.openlibrary.org/b/id/$coverId-M.jpg'
                            : '';
                        return ListTile(
                          leading: cover.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    cover,
                                    width: 40,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.book,
                                      color: Color(0xFFA63D30),
                                    ),
                                  ),
                                )
                              : const Icon(Icons.book, color: Color(0xFFA63D30)),
                          title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text(
                            authors,
                            style: const TextStyle(color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            if (!mounted) return;
                            final gutenbergIds =
                                book['id_project_gutenberg'] as List?;
                            final gutenbergId =
                                gutenbergIds?.isNotEmpty == true
                                    ? gutenbergIds!.first.toString()
                                    : null;
                            setState(() {
                              myBooks.add({
                                "title": title,
                                "author": authors,
                                "content": gutenbergId != null
                                    ? "Click to download..."
                                    : "Not available for free download",
                                "id": gutenbergId,
                                "type": "classic",
                                "progress": 0.0,
                                "cover": cover,
                              });
                            });
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final classics = myBooks.where((b) => b['type'] != 'upload').toList();
    final uploads = myBooks.where((b) => b['type'] == 'upload').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFF0),
      appBar: AppBar(
        title: const Text(
          "My Library",
          style: TextStyle(color: Color(0xFF373737), fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFA63D30)))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 10, 20, 16),
                    child: Text(
                      "Books",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                    ),
                  ),
                  SizedBox(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: classics.length,
                      itemBuilder: (context, index) {
                        return _buildWideBookCard(myBooks.indexOf(classics[index]));
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(height: 1, color: const Color(0xFF373737)),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Text(
                      "My Files",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                    ),
                  ),
                  if (uploads.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text("No files yet", style: TextStyle(color: Colors.grey)),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: uploads
                            .map((book) => _buildFileCard(myBooks.indexOf(book)))
                            .toList(),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Container(height: 1, color: const Color(0xFF373737)),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      "ADD TO LIBRARY",
                      style: TextStyle(
                        letterSpacing: 2,
                        fontWeight: FontWeight.w300,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GestureDetector(
                      onTap: _uploadLocalFile,
                      child: Container(
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF373737),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.upload_file, color: Color(0xFFFFFFF0), size: 36),
                            SizedBox(height: 8),
                            Text("Upload .txt File",
                                style: TextStyle(color: Colors.white70, fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GestureDetector(
                      onTap: _addBook,
                      child: Container(
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFA63D30),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle_outline, color: Color(0xFFFFFFF0), size: 36),
                            SizedBox(height: 8),
                            Text("Add Book",
                                style: TextStyle(color: Color(0xFFFFFFF0), fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GestureDetector(
                      onTap: _downloadFromUrl,
                      child: Container(
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C3E50),
                           borderRadius: BorderRadius.circular(16),
                            ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.link, color: Color(0xFFFFFFF0), size: 36),
                              SizedBox(height: 8),
                              Text("Download from URL",
                                style: TextStyle(color: Color(0xFFFFFFF0), fontSize: 14)),
                            ],
                          ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildWideBookCard(int index) {
    final book = myBooks[index];
    final progress = (book['progress'] as double?) ?? 0.0;
    final cover = book['cover'] as String? ?? '';
    final author = book['author'] as String? ?? '';

    return GestureDetector(
      onTap: () {
        final content = book['content'] as String;
        final id = book['id'];
        if (content.contains("Click to download") && id != null) {
          _downloadBook(index);
        } else if (content.contains("Not available")) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("This book is not available for free download."),
            ),
          );
        } else {
          _openBook(book);
        }
      },
      child: Container(
        width: 300,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF373737),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: cover.isNotEmpty
                  ? Image.network(
                      cover,
                      width: 70,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 70,
                        height: 100,
                        color: const Color(0xFF5C4033),
                        child: const Icon(Icons.menu_book, color: Colors.white54, size: 36),
                      ),
                    )
                  : Container(
                      width: 70,
                      height: 100,
                      color: const Color(0xFF5C4033),
                      child: const Icon(Icons.menu_book, color: Colors.white54, size: 36),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    book['title'] as String,
                    style: const TextStyle(
                      color: Color(0xFFFFFFF0),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    author,
                    style: const TextStyle(color: Color(0xFFFFFFF0), fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFA63D30)),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${(progress * 100).toInt()}% read",
                    style: const TextStyle(color: Color(0xFFFFFFF0), fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileCard(int index) {
    final book = myBooks[index];
    return GestureDetector(
      onTap: () => _openBook(book),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF373737),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.insert_drive_file, color: Color(0xFFFDF4E3), size: 36),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                book['title'] as String,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Color(0xFFFDF4E3), size: 16),
          ],
        ),
      ),
    );
  }
}