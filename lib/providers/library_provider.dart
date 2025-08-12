import 'package:flutter/material.dart';
import '../models/blogster_document.dart';
import '../services/blogster_library_service.dart';

class LibraryProvider extends ChangeNotifier {
  final BlogsterLibraryService _libraryService = BlogsterLibraryService();
  BlogsterDocument? _currentDocument;
  String? _error;
  bool _isLoading = false;

  /// Getters
  BlogsterLibraryService get libraryService => _libraryService;
  BlogsterDocument? get currentDocument => _currentDocument;
  String? get error => _error;
  bool get isLoading => _isLoading;
  String? get libraryPath => _libraryService.libraryPath;
  List<BlogsterDocument> get documents => _libraryService.documents;
  List<BlogsterDocument> get unpostedDocuments =>
      _libraryService.unpostedDocuments;
  List<BlogsterDocument> get postedDocuments => _libraryService.postedDocuments;

  /// Initialize the library
  Future<void> initializeLibrary([String? customPath]) async {
    _setLoading(true);
    _setError(null);

    try {
      await _libraryService.initializeLibrary(customPath);
      notifyListeners();
    } catch (e) {
      _setError('Failed to initialize library: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Create a new document
  Future<BlogsterDocument?> createDocument(String content,
      [String? customFilename]) async {
    _setError(null);

    try {
      final document =
          await _libraryService.createDocument(content, customFilename);
      _currentDocument = document;
      notifyListeners();
      return document;
    } catch (e) {
      _setError('Failed to create document: $e');
      return null;
    }
  }

  /// Update the current document
  Future<void> updateCurrentDocument(String content) async {
    if (_currentDocument == null) {
      // Create new document if none exists
      await createDocument(content);
      return;
    }

    _setError(null);

    try {
      final updatedDocument =
          await _libraryService.updateDocument(_currentDocument!.id, content);
      _currentDocument = updatedDocument;
      notifyListeners();
    } catch (e) {
      _setError('Failed to update document: $e');
    }
  }

  /// Update the current document with details (title, tags)
  Future<void> updateCurrentDocumentWithDetails(
    String content, {
    String? title,
    List<String>? tags,
  }) async {
    if (_currentDocument == null) {
      // Create new document if none exists
      await createDocumentWithDetails(content, title: title, tags: tags);
      return;
    }

    _setError(null);

    try {
      final updatedDocument = await _libraryService.updateDocumentWithDetails(
        _currentDocument!.id,
        content,
        title: title,
        tags: tags,
      );
      _currentDocument = updatedDocument;
      notifyListeners();
    } catch (e) {
      _setError('Failed to update document: $e');
    }
  }

  /// Create a new document with details (title, tags)
  Future<BlogsterDocument?> createDocumentWithDetails(
    String content, {
    String? customFilename,
    String? title,
    List<String>? tags,
  }) async {
    _setError(null);

    try {
      final document = await _libraryService.createDocumentWithDetails(
        content,
        customFilename: customFilename,
        title: title,
        tags: tags,
      );
      _currentDocument = document;
      notifyListeners();
      return document;
    } catch (e) {
      _setError('Failed to create document: $e');
      return null;
    }
  }

  /// Load a document as current
  Future<void> loadDocument(String documentId) async {
    _setError(null);

    try {
      final document = _libraryService.getDocument(documentId);
      if (document != null) {
        _currentDocument = document;
        notifyListeners();
      } else {
        _setError('Document not found');
      }
    } catch (e) {
      _setError('Failed to load document: $e');
    }
  }

  /// Rename a document
  Future<void> renameDocument(String documentId, String newFilename) async {
    _setError(null);

    try {
      final updatedDocument =
          await _libraryService.renameDocument(documentId, newFilename);

      // Update current document if it was renamed
      if (_currentDocument?.id == documentId) {
        _currentDocument = updatedDocument;
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to rename document: $e');
    }
  }

  /// Mark a document as posted
  Future<void> markDocumentAsPosted(
    String documentId, {
    List<String>? tags,
    List<String>? publishedPlatforms,
  }) async {
    _setError(null);

    try {
      final updatedDocument = await _libraryService.markAsPosted(
        documentId,
        tags: tags,
        publishedPlatforms: publishedPlatforms,
      );

      // Update current document if it was marked as posted
      if (_currentDocument?.id == documentId) {
        _currentDocument = updatedDocument;
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to mark document as posted: $e');
    }
  }

  /// Delete a document
  Future<void> deleteDocument(String documentId) async {
    _setError(null);

    try {
      await _libraryService.deleteDocument(documentId);

      // Clear current document if it was deleted
      if (_currentDocument?.id == documentId) {
        _currentDocument = null;
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to delete document: $e');
    }
  }

  /// Create a new document (start fresh)
  void createNewDocument() {
    _currentDocument = null;
    notifyListeners();
  }

  /// Refresh the library
  Future<void> refresh() async {
    _setLoading(true);
    _setError(null);

    try {
      await _libraryService.refresh();
      notifyListeners();
    } catch (e) {
      _setError('Failed to refresh library: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Change library location
  Future<void> changeLibraryLocation(String newPath) async {
    _setLoading(true);
    _setError(null);

    try {
      await _libraryService.changeLibraryLocation(newPath);
      _currentDocument = null; // Clear current document when changing location
      notifyListeners();
    } catch (e) {
      _setError('Failed to change library location: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Check if document has unsaved changes
  bool hasUnsavedChanges(String content) {
    if (_currentDocument == null) return content.trim().isNotEmpty;
    return _currentDocument!.content != content;
  }

  /// Auto-save current document
  Future<void> autoSave(String content) async {
    // For empty content, only create a document if there's no current document
    // and the user is actively typing (we'll create it on first character)
    if (content.trim().isEmpty) {
      return; // Don't auto-save empty content
    }

    if (_currentDocument == null) {
      // Create new document for non-empty content
      await createDocument(content);
    } else if (hasUnsavedChanges(content)) {
      // Update existing document
      await updateCurrentDocument(content);
    }
  }

  /// Auto-save current document with details (title, tags from EditorProvider)
  Future<void> autoSaveWithDetails(
    String content, {
    String? title,
    List<String>? tags,
  }) async {
    // For empty content, only create a document if there's no current document
    // and the user is actively typing (we'll create it on first character)
    if (content.trim().isEmpty) {
      return; // Don't auto-save empty content
    }

    if (_currentDocument == null) {
      // Create new document for non-empty content with details
      await createDocumentWithDetails(content, title: title, tags: tags);
    } else if (hasUnsavedChanges(content) || hasUnsavedDetails(title, tags)) {
      // Update existing document with details
      await updateCurrentDocumentWithDetails(content, title: title, tags: tags);
    }
  }

  /// Check if there are unsaved details (title or tags)
  bool hasUnsavedDetails(String? title, List<String>? tags) {
    if (_currentDocument == null) return false;

    // Check title changes
    if (title != null && title.isNotEmpty && title != _currentDocument!.title) {
      return true;
    }

    // Check tags changes
    if (tags != null) {
      final currentTags = Set<String>.from(_currentDocument!.tags);
      final newTags = Set<String>.from(tags);
      if (currentTags.length != newTags.length ||
          !currentTags.containsAll(newTags)) {
        return true;
      }
    }

    return false;
  }

  /// Create a new document immediately (for "New" button)
  Future<BlogsterDocument?> createNewDocumentFile() async {
    _setError(null);

    try {
      // Create a truly blank document - empty string will generate date/time title
      final document = await _libraryService.createDocument('');
      _currentDocument = document;
      notifyListeners();
      return document;
    } catch (e) {
      _setError('Failed to create new document: $e');
      return null;
    }
  }

  /// Private helper methods
  void _setLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    if (error != null) {
      notifyListeners();
    }
  }
}
