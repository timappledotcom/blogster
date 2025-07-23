import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
    this.isDefault = false,
  });

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
        id: json['id'] as String,
        name: json['name'] as String,
        privateKey: json['privateKey'] as String,
        publicKey: json['publicKey'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        isDefault: json['isDefault'] as bool? ?? false,
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

  String get shortPublicKey => publicKey.length > 16
      ? '${publicKey.substring(0, 8)}...${publicKey.substring(publicKey.length - 8)}'
      : publicKey;
}

class NostrCredentialsService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  static const String _credentialsKey = 'nostr_credentials';
  static const String _defaultCredentialKey = 'default_nostr_credential';

  /// Get all stored Nostr credentials
  Future<List<NostrCredential>> getCredentials() async {
    try {
      final credentialsJson = await _storage.read(key: _credentialsKey);
      if (credentialsJson == null) {
        return [];
      }

      final credentialsList = jsonDecode(credentialsJson) as List;
      return credentialsList
          .map((json) => NostrCredential.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading credentials: $e');
      return [];
    }
  }

  /// Save a new credential or update existing one
  Future<void> saveCredential(NostrCredential credential) async {
    try {
      final credentials = await getCredentials();

      // Remove existing credential with same ID
      credentials.removeWhere((c) => c.id == credential.id);

      // If this is set as default, remove default from others
      if (credential.isDefault) {
        for (int i = 0; i < credentials.length; i++) {
          if (credentials[i].isDefault) {
            credentials[i] = credentials[i].copyWith(isDefault: false);
          }
        }
      }

      // Add the new/updated credential
      credentials.add(credential);

      // Save back to storage
      final credentialsJson =
          jsonEncode(credentials.map((c) => c.toJson()).toList());
      await _storage.write(key: _credentialsKey, value: credentialsJson);

      // Update default credential reference if needed
      if (credential.isDefault) {
        await _storage.write(key: _defaultCredentialKey, value: credential.id);
      }
    } catch (e) {
      print('Error saving credential: $e');
      rethrow;
    }
  }

  /// Delete a credential
  Future<void> deleteCredential(String credentialId) async {
    try {
      final credentials = await getCredentials();
      final wasDefault =
          credentials.any((c) => c.id == credentialId && c.isDefault);

      credentials.removeWhere((c) => c.id == credentialId);

      // If we deleted the default, set first remaining as default
      if (wasDefault && credentials.isNotEmpty) {
        credentials[0] = credentials[0].copyWith(isDefault: true);
        await _storage.write(
            key: _defaultCredentialKey, value: credentials[0].id);
      } else if (credentials.isEmpty) {
        await _storage.delete(key: _defaultCredentialKey);
      }

      // Save updated list
      final credentialsJson =
          jsonEncode(credentials.map((c) => c.toJson()).toList());
      await _storage.write(key: _credentialsKey, value: credentialsJson);
    } catch (e) {
      print('Error deleting credential: $e');
      rethrow;
    }
  }

  /// Get the default credential
  Future<NostrCredential?> getDefaultCredential() async {
    try {
      final credentials = await getCredentials();
      if (credentials.isEmpty) return null;

      // Look for explicitly marked default
      final defaultCred = credentials.where((c) => c.isDefault).firstOrNull;
      if (defaultCred != null) return defaultCred;

      // If no default marked, return first one and mark it as default
      if (credentials.isNotEmpty) {
        final firstCred = credentials[0].copyWith(isDefault: true);
        await saveCredential(firstCred);
        return firstCred;
      }

      return null;
    } catch (e) {
      print('Error getting default credential: $e');
      return null;
    }
  }

  /// Set a credential as default
  Future<void> setDefaultCredential(String credentialId) async {
    try {
      final credentials = await getCredentials();
      bool found = false;

      for (int i = 0; i < credentials.length; i++) {
        if (credentials[i].id == credentialId) {
          credentials[i] = credentials[i].copyWith(isDefault: true);
          found = true;
        } else if (credentials[i].isDefault) {
          credentials[i] = credentials[i].copyWith(isDefault: false);
        }
      }

      if (!found) {
        throw Exception('Credential not found: $credentialId');
      }

      // Save updated list
      final credentialsJson =
          jsonEncode(credentials.map((c) => c.toJson()).toList());
      await _storage.write(key: _credentialsKey, value: credentialsJson);
      await _storage.write(key: _defaultCredentialKey, value: credentialId);
    } catch (e) {
      print('Error setting default credential: $e');
      rethrow;
    }
  }

  /// Generate a new random Nostr credential
  Future<NostrCredential> generateCredential(String name) async {
    try {
      // Generate random 32-byte private key
      final random = Random.secure();
      final privateKeyBytes =
          Uint8List.fromList(List.generate(32, (i) => random.nextInt(256)));

      // Generate corresponding public key using our BIP-340 implementation
      final publicKeyBytes =
          CorrectedBIP340Schnorr.getXOnlyPublicKey(privateKeyBytes);

      final credential = NostrCredential(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        privateKey: _bytesToHex(privateKeyBytes),
        publicKey: _bytesToHex(publicKeyBytes),
        createdAt: DateTime.now(),
        isDefault: false,
      );

      return credential;
    } catch (e) {
      print('Error generating credential: $e');
      rethrow;
    }
  }

  /// Import credential from private key (hex)
  Future<NostrCredential> importCredential(
      String name, String privateKeyHex) async {
    try {
      // Validate and clean private key
      String cleanKey = privateKeyHex.trim();
      if (cleanKey.startsWith('0x')) {
        cleanKey = cleanKey.substring(2);
      }

      if (cleanKey.length != 64) {
        throw Exception('Private key must be 64 hex characters (32 bytes)');
      }

      final privateKeyBytes = _hexToBytes(cleanKey);
      if (privateKeyBytes.length != 32) {
        throw Exception('Invalid private key length');
      }

      // Generate corresponding public key
      final publicKeyBytes =
          CorrectedBIP340Schnorr.getXOnlyPublicKey(privateKeyBytes);

      final credential = NostrCredential(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        privateKey: cleanKey,
        publicKey: _bytesToHex(publicKeyBytes),
        createdAt: DateTime.now(),
        isDefault: false,
      );

      return credential;
    } catch (e) {
      print('Error importing credential: $e');
      rethrow;
    }
  }

  /// Clear all stored credentials (for testing/reset)
  Future<void> clearAllCredentials() async {
    try {
      await _storage.delete(key: _credentialsKey);
      await _storage.delete(key: _defaultCredentialKey);
    } catch (e) {
      print('Error clearing credentials: $e');
      rethrow;
    }
  }

  /// Export credential (returns private key hex for backup)
  String exportCredential(NostrCredential credential) {
    return credential.privateKey;
  }

  /// Validate if a credential's keys are valid
  Future<bool> validateCredential(NostrCredential credential) async {
    try {
      final privateKeyBytes = _hexToBytes(credential.privateKey);
      final expectedPublicKeyBytes =
          CorrectedBIP340Schnorr.getXOnlyPublicKey(privateKeyBytes);
      final expectedPublicKey = _bytesToHex(expectedPublicKeyBytes);

      return expectedPublicKey == credential.publicKey;
    } catch (e) {
      print('Error validating credential: $e');
      return false;
    }
  }

  // Utility methods
  Uint8List _hexToBytes(String hex) {
    if (hex.length % 2 != 0) hex = '0$hex';
    return Uint8List.fromList(List.generate(hex.length ~/ 2,
        (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16)));
  }

  String _bytesToHex(Uint8List bytes) {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }
}

// Extension to provide firstOrNull for older Dart versions
extension FirstWhereOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) {
      return iterator.current;
    }
    return null;
  }
}
