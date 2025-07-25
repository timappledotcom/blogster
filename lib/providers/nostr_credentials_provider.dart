import 'package:flutter/foundation.dart';
import '../services/nostr_credentials_service_encrypted.dart';

class NostrCredentialsProvider extends ChangeNotifier {
  final NostrCredentialsService _credentialsService = NostrCredentialsService();

  List<NostrCredential> _credentials = [];
  NostrCredential? _currentCredential;
  bool _isLoading = false;
  String? _error;

  List<NostrCredential> get credentials => _credentials;
  NostrCredential? get currentCredential => _currentCredential;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasCredentials => _credentials.isNotEmpty;

  /// Load all credentials from secure storage
  Future<void> loadCredentials() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _credentials = await _credentialsService.getAllCredentials();
      _currentCredential = await _credentialsService.getDefaultCredential();
    } catch (e) {
      _error = 'Failed to load credentials: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Generate a new random credential
  Future<void> generateCredential(String name,
      {bool setAsDefault = false}) async {
    _setLoading(true);
    _clearError();

    try {
      await _credentialsService.generateCredential(name,
          setAsDefault: setAsDefault);
      await loadCredentials();
    } catch (e) {
      _setError('Failed to generate credential: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Import credential from private key
  Future<void> importCredential(String name, String privateKeyHex,
      {bool setAsDefault = false}) async {
    _setLoading(true);
    _clearError();

    try {
      await _credentialsService.importCredential(name, privateKeyHex,
          setAsDefault: setAsDefault);
      await loadCredentials();
    } catch (e) {
      _setError('Failed to import credential: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a credential
  Future<void> deleteCredential(String credentialId) async {
    _setLoading(true);
    _clearError();

    try {
      await _credentialsService.deleteCredential(credentialId);
      await loadCredentials();
    } catch (e) {
      _setError('Failed to delete credential: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Set a credential as the current/default one
  Future<void> setCurrentCredential(String credentialId) async {
    _setLoading(true);
    _clearError();

    try {
      await _credentialsService.setDefaultCredential(credentialId);
      await loadCredentials();
    } catch (e) {
      _setError('Failed to set current credential: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Update a credential's name
  Future<void> updateCredentialName(String credentialId, String newName) async {
    _setLoading(true);
    _clearError();

    try {
      await _credentialsService.updateCredentialName(credentialId, newName);
      await loadCredentials();
    } catch (e) {
      _setError('Failed to update credential name: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Export a credential's private key
  Future<String?> exportCredential(String credentialId) async {
    try {
      return await _credentialsService.exportCredential(credentialId);
    } catch (e) {
      _setError('Failed to export credential: $e');
      return null;
    }
  }

  /// Check if a credential name is already taken
  Future<bool> isNameTaken(String name, {String? excludeId}) async {
    try {
      return await _credentialsService.isNameTaken(name, excludeId: excludeId);
    } catch (e) {
      _setError('Failed to check name availability: $e');
      return false;
    }
  }

  /// Clear all credentials (for testing/reset)
  Future<void> clearAllCredentials() async {
    _setLoading(true);
    _clearError();

    try {
      await _credentialsService.clearAllCredentials();
      await loadCredentials();
    } catch (e) {
      _setError('Failed to clear credentials: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) _error = null;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }
}
