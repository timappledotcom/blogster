import 'dart:convert';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'microblog_service.dart';

class MicroblogCredentialsService {
  static const String _storageKey = 'microblog_credentials';
  static const String _defaultCredentialKey = 'microblog_default_credential';

  final EncryptedSharedPreferences _storage = EncryptedSharedPreferences();

  /// Get all stored Micro.blog credentials
  Future<List<MicroblogCredential>> getAllCredentials() async {
    try {
      final credentialsJson = await _storage.getString(_storageKey);
      if (credentialsJson.isEmpty) return [];

      final List<dynamic> credentialsList = jsonDecode(credentialsJson);
      return credentialsList
          .map((json) => MicroblogCredential.fromJson(json))
          .toList();
    } catch (e) {
      print('Error loading Micro.blog credentials: $e');
      return [];
    }
  }

  /// Save credentials to secure storage
  Future<void> _saveCredentials(List<MicroblogCredential> credentials) async {
    final credentialsJson = jsonEncode(
      credentials.map((cred) => cred.toJson()).toList(),
    );
    await _storage.setString(_storageKey, credentialsJson);
  }

  /// Add a new credential
  Future<void> addCredential({
    required String name,
    required String appToken,
    required String blogUrl,
    bool setAsDefault = false,
  }) async {
    final credentials = await getAllCredentials();

    // Check if name already exists
    if (credentials.any((cred) => cred.name == name)) {
      throw Exception('A credential with this name already exists');
    }

    final newCredential = MicroblogCredential(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      appToken: appToken,
      blogUrl: blogUrl,
      createdAt: DateTime.now(),
    );

    credentials.add(newCredential);
    await _saveCredentials(credentials);

    if (setAsDefault || credentials.length == 1) {
      await setDefaultCredential(newCredential.id);
    }
  }

  /// Delete a credential
  Future<void> deleteCredential(String credentialId) async {
    final credentials = await getAllCredentials();
    credentials.removeWhere((cred) => cred.id == credentialId);
    await _saveCredentials(credentials);

    // If this was the default credential, clear the default
    final defaultId = await _storage.getString(_defaultCredentialKey);
    if (defaultId == credentialId) {
      await _storage.remove(_defaultCredentialKey);
    }
  }

  /// Update a credential's name
  Future<void> updateCredentialName(String credentialId, String newName) async {
    final credentials = await getAllCredentials();

    // Check if new name already exists (excluding current credential)
    if (credentials
        .any((cred) => cred.name == newName && cred.id != credentialId)) {
      throw Exception('A credential with this name already exists');
    }

    final index = credentials.indexWhere((cred) => cred.id == credentialId);
    if (index == -1) {
      throw Exception('Credential not found');
    }

    final oldCredential = credentials[index];
    credentials[index] = MicroblogCredential(
      id: oldCredential.id,
      name: newName,
      appToken: oldCredential.appToken,
      blogUrl: oldCredential.blogUrl,
      createdAt: oldCredential.createdAt,
    );

    await _saveCredentials(credentials);
  }

  /// Set default credential
  Future<void> setDefaultCredential(String credentialId) async {
    final credentials = await getAllCredentials();
    if (!credentials.any((cred) => cred.id == credentialId)) {
      throw Exception('Credential not found');
    }
    await _storage.setString(_defaultCredentialKey, credentialId);
  }

  /// Get default credential
  Future<MicroblogCredential?> getDefaultCredential() async {
    final defaultId = await _storage.getString(_defaultCredentialKey);
    if (defaultId.isEmpty) return null;

    final credentials = await getAllCredentials();
    try {
      return credentials.firstWhere((cred) => cred.id == defaultId);
    } catch (e) {
      // Default credential not found, clear the reference
      await _storage.remove(_defaultCredentialKey);
      return null;
    }
  }

  /// Check if a name is already taken
  Future<bool> isNameTaken(String name, {String? excludeId}) async {
    final credentials = await getAllCredentials();
    return credentials.any((cred) =>
        cred.name == name && (excludeId == null || cred.id != excludeId));
  }

  /// Clear all credentials (for testing/reset)
  Future<void> clearAllCredentials() async {
    await _storage.remove(_storageKey);
    await _storage.remove(_defaultCredentialKey);
  }

  /// Export a credential's app token (for backup purposes)
  Future<String?> exportCredential(String credentialId) async {
    final credentials = await getAllCredentials();
    try {
      final credential =
          credentials.firstWhere((cred) => cred.id == credentialId);
      return credential.appToken;
    } catch (e) {
      return null;
    }
  }
}
