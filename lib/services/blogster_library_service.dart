import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import '../models/blogster_document.dart';

class BlogsterLibraryService {
  static const String _defaultFolderName = 'blogster';
  static const String _postedFolderName = 'posted';
  static const String _metadataFileName = '.blogster_metadata.json';

  String? _libraryPath;
  final Map<String, BlogsterDocument> _documents = {};

  /// Get the current library path
  String? get libraryPath => _libraryPath;

  /// Get all documents
  List<BlogsterDocument> get documents => _documents.values.toList();

  /// Get unposted documents
  List<BlogsterDocument> get unpostedDocuments =>
      _documents.values.where((doc) => !doc.isPosted).toList();

  /// Get posted documents
  List<BlogsterDocument> get postedDocuments =>
      _documents.values.where((doc) => doc.isPosted).toList();

  /// Initialize the library with a specific path or default to Documents
  Future<void> initializeLibrary([String? customPath]) async {
    try {
      String libraryPath;

      if (customPath != null) {
        libraryPath = customPath;
      } else {
        // Default to Documents folder
        final homeDir = Platform.environment['HOME'] ??
            Platform.environment['USERPROFILE'] ??
            '';
        libraryPath = path.join(homeDir, 'Documents', _defaultFolderName);
      }

      final libraryDir = Directory(libraryPath);
      if (!await libraryDir.exists()) {
        await libraryDir.create(recursive: true);
      }

      final postedDir = Directory(path.join(libraryPath, _postedFolderName));
      if (!await postedDir.exists()) {
        await postedDir.create(recursive: true);
      }

      _libraryPath = libraryPath;
      await _loadDocuments();

      print('Library initialized at: $libraryPath');
    } catch (e) {
      print('Error initializing library: $e');
      throw Exception('Failed to initialize library: $e');
    }
  }

  /// Load all documents from the library
  Future<void> _loadDocuments() async {
    if (_libraryPath == null) return;

    try {
      _documents.clear();

      // Load unposted documents
      await _loadDocumentsFromDirectory(_libraryPath!, false);

      // Load posted documents
      final postedPath = path.join(_libraryPath!, _postedFolderName);
      await _loadDocumentsFromDirectory(postedPath, true);

      print('Loaded ${_documents.length} documents');
    } catch (e) {
      print('Error loading documents: $e');
    }
  }

  /// Load documents from a specific directory
  Future<void> _loadDocumentsFromDirectory(
      String dirPath, bool isPosted) async {
    final dir = Directory(dirPath);
    if (!await dir.exists()) return;

    await for (final entity in dir.list()) {
      if (entity is File && entity.path.endsWith('.md')) {
        try {
          final content = await entity.readAsString();
          final filename = path.basename(entity.path);
          final title = BlogsterDocument.extractTitle(content);
          final stat = await entity.stat();

          // Load document metadata if available
          final metadata = await _loadDocumentMetadata(entity.path);
          final tags = metadata?['tags'] != null
              ? List<String>.from(metadata!['tags'])
              : <String>[];
          final publishedPlatforms = metadata?['publishedPlatforms'] != null
              ? List<String>.from(metadata!['publishedPlatforms'])
              : <String>[];

          final document = BlogsterDocument(
            id: _generateId(entity.path),
            filename: filename,
            title: title,
            content: content,
            createdAt: stat.changed,
            modifiedAt: stat.modified,
            isPosted: isPosted,
            filePath: entity.path,
            tags: tags,
            publishedPlatforms: publishedPlatforms,
          );

          _documents[document.id] = document;
        } catch (e) {
          print('Error loading document ${entity.path}: $e');
        }
      }
    }
  }

  /// Create a new document
  Future<BlogsterDocument> createDocument(String content,
      [String? customFilename]) async {
    if (_libraryPath == null) {
      throw Exception('Library not initialized');
    }

    final title = BlogsterDocument.extractTitle(content);
    final filename = customFilename ?? BlogsterDocument.generateFilename(title);
    final filePath = path.join(_libraryPath!, filename);

    // Ensure unique filename
    final uniqueFilePath = await _ensureUniqueFilename(filePath);
    final uniqueFilename = path.basename(uniqueFilePath);

    final now = DateTime.now();
    final document = BlogsterDocument(
      id: _generateId(uniqueFilePath),
      filename: uniqueFilename,
      title: title,
      content: content,
      createdAt: now,
      modifiedAt: now,
      isPosted: false,
      filePath: uniqueFilePath,
    );

    // Save to file
    final file = File(uniqueFilePath);
    await file.writeAsString(content);

    _documents[document.id] = document;
    await _saveMetadata();

    print('Created document: $uniqueFilename');
    return document;
  }

  /// Update an existing document
  Future<BlogsterDocument> updateDocument(
      String documentId, String content) async {
    final document = _documents[documentId];
    if (document == null) {
      throw Exception('Document not found');
    }

    final title = BlogsterDocument.extractTitle(content);
    final updatedDocument = document.copyWith(
      title: title,
      content: content,
      modifiedAt: DateTime.now(),
    );

    // Save to file
    final file = File(document.filePath);
    await file.writeAsString(content);

    _documents[documentId] = updatedDocument;
    await _saveMetadata();

    return updatedDocument;
  }

  /// Rename a document
  Future<BlogsterDocument> renameDocument(
      String documentId, String newFilename) async {
    final document = _documents[documentId];
    if (document == null) {
      throw Exception('Document not found');
    }

    // Ensure .md extension
    if (!newFilename.endsWith('.md')) {
      newFilename += '.md';
    }

    final currentFile = File(document.filePath);
    final newPath = path.join(
        document.isPosted
            ? path.join(_libraryPath!, _postedFolderName)
            : _libraryPath!,
        newFilename);

    // Ensure unique filename
    final uniquePath = await _ensureUniqueFilename(newPath);
    final uniqueFilename = path.basename(uniquePath);

    // Rename the file
    await currentFile.rename(uniquePath);

    final updatedDocument = document.copyWith(
      filename: uniqueFilename,
      filePath: uniquePath,
      modifiedAt: DateTime.now(),
    );

    _documents[documentId] = updatedDocument;
    await _saveMetadata();

    print('Renamed document to: $uniqueFilename');
    return updatedDocument;
  }

  /// Mark a document as posted and move to posted folder
  Future<BlogsterDocument> markAsPosted(
    String documentId, {
    List<String>? tags,
    List<String>? publishedPlatforms,
  }) async {
    final document = _documents[documentId];
    if (document == null) {
      throw Exception('Document not found');
    }

    if (document.isPosted) return document; // Already posted

    final postedPath = path.join(_libraryPath!, _postedFolderName);
    final newFilePath = path.join(postedPath, document.filename);

    // Ensure unique filename in posted folder
    final uniquePath = await _ensureUniqueFilename(newFilePath);

    // Move the file
    final currentFile = File(document.filePath);
    await currentFile.rename(uniquePath);

    final updatedDocument = document.copyWith(
      isPosted: true,
      filePath: uniquePath,
      filename: path.basename(uniquePath),
      modifiedAt: DateTime.now(),
      tags: tags ?? document.tags,
      publishedPlatforms: publishedPlatforms ?? document.publishedPlatforms,
    );

    _documents[documentId] = updatedDocument;
    await _saveMetadata();
    await _saveDocumentMetadata(updatedDocument);

    print('Moved document to posted folder: ${updatedDocument.filename}');
    return updatedDocument;
  }

  /// Delete a document
  Future<void> deleteDocument(String documentId) async {
    final document = _documents[documentId];
    if (document == null) {
      throw Exception('Document not found');
    }

    final file = File(document.filePath);
    if (await file.exists()) {
      await file.delete();
    }

    _documents.remove(documentId);
    await _saveMetadata();

    print('Deleted document: ${document.filename}');
  }

  /// Get a document by ID
  BlogsterDocument? getDocument(String documentId) {
    return _documents[documentId];
  }

  /// Ensure filename is unique by adding a number suffix if needed
  Future<String> _ensureUniqueFilename(String filePath) async {
    if (!await File(filePath).exists()) return filePath;

    final dir = path.dirname(filePath);
    final name = path.basenameWithoutExtension(filePath);
    final ext = path.extension(filePath);

    int counter = 1;
    String newPath;
    do {
      newPath = path.join(dir, '${name}_$counter$ext');
      counter++;
    } while (await File(newPath).exists());

    return newPath;
  }

  /// Generate a unique ID for a document based on its path
  String _generateId(String filePath) {
    return filePath.hashCode.abs().toString();
  }

  /// Save metadata to file
  Future<void> _saveMetadata() async {
    if (_libraryPath == null) return;

    try {
      final metadataFile = File(path.join(_libraryPath!, _metadataFileName));
      final metadata = {
        'version': '1.0',
        'lastUpdated': DateTime.now().toIso8601String(),
        'documentCount': _documents.length,
      };

      await metadataFile.writeAsString(jsonEncode(metadata));
    } catch (e) {
      print('Error saving metadata: $e');
    }
  }

  /// Save individual document metadata (tags, published platforms, etc.)
  Future<void> _saveDocumentMetadata(BlogsterDocument document) async {
    if (_libraryPath == null) return;

    try {
      // Create a metadata file alongside the document
      final docMetadataPath = '${document.filePath}.meta';
      final docMetadataFile = File(docMetadataPath);

      final docMetadata = {
        'id': document.id,
        'tags': document.tags,
        'publishedPlatforms': document.publishedPlatforms,
        'isPosted': document.isPosted,
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      await docMetadataFile.writeAsString(jsonEncode(docMetadata));
    } catch (e) {
      print('Error saving document metadata: $e');
    }
  }

  /// Load individual document metadata
  Future<Map<String, dynamic>?> _loadDocumentMetadata(String filePath) async {
    try {
      final docMetadataPath = '$filePath.meta';
      final docMetadataFile = File(docMetadataPath);

      if (await docMetadataFile.exists()) {
        final content = await docMetadataFile.readAsString();
        return jsonDecode(content);
      }
    } catch (e) {
      print('Error loading document metadata for $filePath: $e');
    }
    return null;
  }

  /// Refresh the library (reload all documents)
  Future<void> refresh() async {
    await _loadDocuments();
  }

  /// Change library location
  Future<void> changeLibraryLocation(String newPath) async {
    await initializeLibrary(newPath);
  }
}
