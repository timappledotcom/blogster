import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:convert/convert.dart';
import '../crypto/corrected_bip340_schnorr.dart';

class NostrCredential {
  final String id;
  final String name;
  final String privateKey; // hex string
  final String publicKey; // hex string
  final DateTime createdAt;
  final bool isDefault;

  const NostrCredential({
    required this.id,
    required this.name,
    required this.privateKey,
    required this.publicKey,
    required this.createdAt,
    required this.isDefault,
  });

  String get shortPublicKey {
    if (publicKey.length <= 16) return publicKey;
    return '${publicKey.substring(0, 8)}...${publicKey.substring(publicKey.length - 8)}';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'privateKey': privateKey,
        'publicKey': publicKey,
        'createdAt': createdAt.toIso8601String(),
        'isDefault': isDefault,
      };

  factory NostrCredential.fromJson(Map<String, dynamic> json) =>
      NostrCredential(
        id: json['id'],
        name: json['name'],
        privateKey: json['privateKey'],
        publicKey: json['publicKey'],
        createdAt: DateTime.parse(json['createdAt']),
        isDefault: json['isDefault'] ?? false,
      );

  NostrCredential copyWith({
    String? id,
    String? name,
    String? privateKey,
    String? publicKey,
    DateTime? createdAt,
    bool? isDefault,
  }) =>
      NostrCredential(
        id: id ?? this.id,
        name: name ?? this.name,
        privateKey: privateKey ?? this.privateKey,
        publicKey: publicKey ?? this.publicKey,
        createdAt: createdAt ?? this.createdAt,
        isDefault: isDefault ?? this.isDefault,
      );
}

class NostrCredentialsService {
  static const String _credentialsKey = 'nostr_credentials';
  static const String _defaultCredentialKey = 'default_credential_id';

  late final EncryptedSharedPreferences _encryptedPrefs;

  NostrCredentialsService() {
    _encryptedPrefs = EncryptedSharedPreferences();
  }

  /// Generate a new Nostr credential with a random private key
  Future<NostrCredential> generateCredential(String name,
      {bool setAsDefault = false}) async {
    print('Generating new credential: $name');
    try {
      // Generate random 32-byte private key
      final random = Random.secure();
      final privateKeyBytes = Uint8List(32);
      for (int i = 0; i < 32; i++) {
        privateKeyBytes[i] = random.nextInt(256);
      }

      final privateKeyHex = privateKeyBytes
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join();

      // Generate public key from private key using BIP-340
      final publicKeyBytes =
          CorrectedBIP340Schnorr.getXOnlyPublicKey(privateKeyBytes);
      final publicKeyHex = hex.encode(publicKeyBytes);

      final credential = NostrCredential(
        id: _generateId(),
        name: name,
        privateKey: privateKeyHex,
        publicKey: publicKeyHex,
        createdAt: DateTime.now(),
        isDefault: setAsDefault,
      );

      await _storeCredential(credential);

      if (setAsDefault) {
        await _setDefaultCredential(credential.id);
      }

      print('Generated credential successfully');
      return credential;
    } catch (e) {
      print('Error generating credential: $e');
      rethrow;
    }
  }

  /// Import an existing credential from a private key
  Future<NostrCredential> importCredential(String name, String privateKeyHex,
      {bool setAsDefault = false}) async {
    print('Importing credential: $name');
    try {
      // Validate private key length
      if (privateKeyHex.length != 64) {
        throw ArgumentError(
            'Invalid private key length. Must be 64 hex characters.');
      }

      // Convert hex to bytes
      final privateKeyBytes = Uint8List.fromList(List.generate(
          32,
          (i) =>
              int.parse(privateKeyHex.substring(i * 2, i * 2 + 2), radix: 16)));

      // Generate public key from private key using BIP-340
      final publicKeyBytes =
          CorrectedBIP340Schnorr.getXOnlyPublicKey(privateKeyBytes);
      final publicKeyHex = hex.encode(publicKeyBytes);

      final credential = NostrCredential(
        id: _generateId(),
        name: name,
        privateKey: privateKeyHex.toLowerCase(),
        publicKey: publicKeyHex,
        createdAt: DateTime.now(),
        isDefault: setAsDefault,
      );

      await _storeCredential(credential);

      if (setAsDefault) {
        await _setDefaultCredential(credential.id);
      }

      print('Imported credential successfully');
      return credential;
    } catch (e) {
      print('Error importing credential: $e');
      rethrow;
    }
  }

  /// Get all stored credentials
  Future<List<NostrCredential>> getAllCredentials() async {
    try {
      final credentialsJson = await _encryptedPrefs.getString(_credentialsKey);
      if (credentialsJson.isEmpty) {
        return [];
      }

      final List<dynamic> credentialsList = jsonDecode(credentialsJson);
      return credentialsList
          .map((json) => NostrCredential.fromJson(json))
          .toList();
    } catch (e) {
      print('Error loading credentials: $e');
      return [];
    }
  }

  /// Get the default credential
  Future<NostrCredential?> getDefaultCredential() async {
    try {
      final defaultId = await _encryptedPrefs.getString(_defaultCredentialKey);
      if (defaultId.isEmpty) {
        return null;
      }

      final credentials = await getAllCredentials();
      return credentials.firstWhere(
        (cred) => cred.id == defaultId,
        orElse: () => credentials.isNotEmpty
            ? credentials.first
            : throw StateError('No credentials found'),
      );
    } catch (e) {
      print('Error getting default credential: $e');
      return null;
    }
  }

  /// Set a credential as default
  Future<void> setDefaultCredential(String credentialId) async {
    try {
      await _setDefaultCredential(credentialId);
      print('Set default credential: $credentialId');
    } catch (e) {
      print('Error setting default credential: $e');
      rethrow;
    }
  }

  /// Update a credential's name
  Future<void> updateCredentialName(String credentialId, String newName) async {
    try {
      final credentials = await getAllCredentials();
      final updatedCredentials = credentials.map((cred) {
        if (cred.id == credentialId) {
          return cred.copyWith(name: newName);
        }
        return cred;
      }).toList();

      await _storeAllCredentials(updatedCredentials);
      print('Updated credential name');
    } catch (e) {
      print('Error updating credential name: $e');
      rethrow;
    }
  }

  /// Delete a credential
  Future<void> deleteCredential(String credentialId) async {
    try {
      final credentials = await getAllCredentials();
      final updatedCredentials =
          credentials.where((cred) => cred.id != credentialId).toList();

      await _storeAllCredentials(updatedCredentials);

      // If this was the default credential, clear the default
      final defaultId = await _encryptedPrefs.getString(_defaultCredentialKey);
      if (defaultId == credentialId) {
        await _encryptedPrefs.remove(_defaultCredentialKey);
      }

      print('Deleted credential: $credentialId');
    } catch (e) {
      print('Error deleting credential: $e');
      rethrow;
    }
  }

  /// Export a credential's private key (returns hex format)
  Future<String?> exportCredential(String credentialId) async {
    try {
      final credentials = await getAllCredentials();
      final credential = credentials.firstWhere(
        (cred) => cred.id == credentialId,
        orElse: () => throw ArgumentError('Credential not found'),
      );

      return credential.privateKey;
    } catch (e) {
      print('Error exporting credential: $e');
      return null;
    }
  }

  /// Check if a credential name is already taken
  Future<bool> isNameTaken(String name, {String? excludeId}) async {
    try {
      final credentials = await getAllCredentials();
      return credentials
          .any((cred) => cred.name == name && cred.id != excludeId);
    } catch (e) {
      print('Error checking name availability: $e');
      return false;
    }
  }

  /// Clear all stored credentials (for testing/reset)
  Future<void> clearAllCredentials() async {
    try {
      await _encryptedPrefs.remove(_credentialsKey);
      await _encryptedPrefs.remove(_defaultCredentialKey);
      print('Cleared all credentials');
    } catch (e) {
      print('Error clearing credentials: $e');
      rethrow;
    }
  }

  // Private helper methods
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        Random().nextInt(1000).toString();
  }

  Future<void> _storeCredential(NostrCredential credential) async {
    final credentials = await getAllCredentials();
    credentials.add(credential);
    await _storeAllCredentials(credentials);
  }

  Future<void> _storeAllCredentials(List<NostrCredential> credentials) async {
    final credentialsJson =
        jsonEncode(credentials.map((c) => c.toJson()).toList());
    await _encryptedPrefs.setString(_credentialsKey, credentialsJson);
  }

  Future<void> _setDefaultCredential(String credentialId) async {
    await _encryptedPrefs.setString(_defaultCredentialKey, credentialId);
  }
}
