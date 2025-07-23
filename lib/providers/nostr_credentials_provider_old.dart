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
      await _credentialsService.generateCredential(name, setAsDefault: setAsDefault);
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
      await _credentialsService.importCredential(name, privateKeyHex, setAsDefault: setAsDefault);
      await loadCredentials();
    } catch (e) {
      _setError('Failed to import credential: $e');
    } finally {
      _setLoading(false);
    }
  }
      final credential =
          await _credentialsService.importCredential(name, privateKeyHex);
      await addCredential(credential, setAsDefault: setAsDefault);
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
      await loadCredentials(); // Reload to update current credential if needed
    } catch (e) {
      _setError('Failed to delete credential: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Set a credential as default/current
  Future<void> setCurrentCredential(String credentialId) async {
    _setLoading(true);
    _clearError();

    try {
      await _credentialsService.setCurrentCredential(credentialId);
      await loadCredentials();
    } catch (e) {
      _setError('Failed to set current credential: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Update credential name
  Future<void> updateCredentialName(String credentialId, String newName) async {
    _setLoading(true);
    _clearError();

    try {
      final credential = _credentials.firstWhere((c) => c.id == credentialId);
      final updatedCredential = credential.copyWith(name: newName);
      await _credentialsService.updateCredential(updatedCredential);
      await loadCredentials();
    } catch (e) {
      _setError('Failed to update credential: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Export credential private key
  String? exportCredential(String credentialId) {
    try {
      final credential = _credentials.firstWhere((c) => c.id == credentialId);
      return _credentialsService.exportCredential(credential.id);
    } catch (e) {
      _setError('Failed to export credential: $e');
      return null;
    }
  }

  /// Clear all credentials (for testing/reset)
  Future<void> clearAllCredentials() async {
    _setLoading(true);
    _clearError();

    try {
      await _credentialsService.clearAllCredentials();
      _credentials = [];
      _currentCredential = null;
      notifyListeners();
    } catch (e) {
      _setError('Failed to clear credentials: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Get credential by ID
  NostrCredential? getCredentialById(String credentialId) {
    try {
      return _credentials.firstWhere((c) => c.id == credentialId);
    } catch (e) {
      return null;
    }
  }

  /// Check if a name already exists
  bool isNameTaken(String name, {String? excludeId}) {
    return _credentials.any(
        (c) => c.name.toLowerCase() == name.toLowerCase() && c.id != excludeId);
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
