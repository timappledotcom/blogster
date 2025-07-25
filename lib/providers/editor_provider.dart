import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../services/nostr_service.dart';

enum ViewMode { edit, preview, split }

class EditorProvider extends ChangeNotifier {
  String _content = '''# Welcome to Blogster ✨

**The beautiful markdown editor for modern writers**

Start crafting your next blog post, article, or documentation with Blogster's clean and distraction-free interface.

## Features

- **Live Preview**: Switch between edit, preview, and split modes
- **Dark Mode**: Easy on the eyes for long writing sessions
- **Nostr Publishing**: Share your content on the decentralized web
- **Cross-Platform**: Works seamlessly on Linux, Android, and Windows
- **Syntax Highlighting**: Beautiful code blocks with language support

## Getting Started

1. Start typing in **Edit** mode
2. Switch to **Preview** to see your formatted content
3. Use **Split** mode for side-by-side editing
4. Click the share button to publish to Nostr

## Code Example

Here's a sample Flutter widget with syntax highlighting:

```dart
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Text(
        'Hello, Blogster!',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
```

And here's some JavaScript:

```javascript
function greetUser(name) {
  const message = `Hello, \${name}! Welcome to Blogster.`;
  console.log(message);
  return message;
}

greetUser('Developer');
```

---

*Happy writing! 🚀*''';
  ViewMode _viewMode = ViewMode.edit;
  String? _currentFilePath;
  bool _isLoading = false;
  String? _error;
  List<String> _tags = [];

  final NostrService _nostrService = NostrService();

  String get content => _content;
  ViewMode get viewMode => _viewMode;
  String? get currentFilePath => _currentFilePath;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get tags => List.unmodifiable(_tags);

  void updateContent(String newContent) {
    _content = newContent;
    notifyListeners();
  }

  void setViewMode(ViewMode mode) {
    _viewMode = mode;
    notifyListeners();
  }

  void addTag(String tag) {
    final cleanTag = tag.trim().toLowerCase();
    if (cleanTag.isNotEmpty && !_tags.contains(cleanTag)) {
      _tags.add(cleanTag);
      notifyListeners();
    }
  }

  void removeTag(String tag) {
    _tags.remove(tag);
    notifyListeners();
  }

  void setTags(List<String> newTags) {
    _tags = newTags
        .map((tag) => tag.trim().toLowerCase())
        .where((tag) => tag.isNotEmpty)
        .toList();
    notifyListeners();
  }

  void clearTags() {
    _tags.clear();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> newFile() async {
    _content = '';
    _currentFilePath = null;
    notifyListeners();
  }

  Future<void> openFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['md', 'markdown', 'txt'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        _content = await file.readAsString();
        _currentFilePath = result.files.single.path;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to open file: $e';
      notifyListeners();
    }
  }

  Future<void> saveFile() async {
    if (_currentFilePath != null) {
      await _saveToPath(_currentFilePath!);
    } else {
      await saveAsFile();
    }
  }

  Future<void> saveAsFile() async {
    try {
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save markdown file',
        fileName: 'document.md',
        type: FileType.custom,
        allowedExtensions: ['md'],
      );

      if (outputFile != null) {
        await _saveToPath(outputFile);
        _currentFilePath = outputFile;
      }
    } catch (e) {
      _error = 'Failed to save file: $e';
      notifyListeners();
    }
  }

  Future<void> _saveToPath(String path) async {
    try {
      File file = File(path);
      await file.writeAsString(_content);
    } catch (e) {
      _error = 'Failed to save file: $e';
      notifyListeners();
    }
  }

  Future<void> publishToNostr({
    required String privateKey,
    required List<String> relays,
    String? title,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _nostrService.publishNoteWithPrivateKey(
        content: _content,
        privateKey: privateKey,
        relays: relays,
        title: title,
        tags: _tags,
      );
    } catch (e) {
      _error = 'Failed to publish to Nostr: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
