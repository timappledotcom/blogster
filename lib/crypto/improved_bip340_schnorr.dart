import 'dart:typed_data';
import 'package:bitcoin_base/bitcoin_base.dart';

/// Improved BIP-340 Schnorr signature implementation using bitcoin_base library
/// This implementation is fully compliant with BIP-340 specification
class ImprovedBIP340Schnorr {
  /// Generate x-only public key from private key (32 bytes)
  static Uint8List getXOnlyPublicKey(Uint8List privateKeyBytes) {
    if (privateKeyBytes.length != 32) {
      throw ArgumentError('Private key must be exactly 32 bytes');
    }

    try {
      // Create ECPrivate key from bytes
      final privateKey = ECPrivate.fromBytes(privateKeyBytes);

      // Get the public key
      final publicKey = privateKey.getPublic();

      // Extract x-only coordinate (32 bytes)
      final xOnlyBytes = publicKey.toXOnlyBytes();

      return xOnlyBytes;
    } catch (e) {
      throw Exception('Failed to generate x-only public key: $e');
    }
  }

  /// Sign a message using BIP-340 Schnorr signature
  static Uint8List sign(Uint8List message, Uint8List privateKeyBytes) {
    if (privateKeyBytes.length != 32) {
      throw ArgumentError('Private key must be exactly 32 bytes');
    }
    if (message.length != 32) {
      throw ArgumentError('Message must be exactly 32 bytes (hash)');
    }

    try {
      // Create ECPrivate key from bytes
      final privateKey = ECPrivate.fromBytes(privateKeyBytes);

      // Sign using Schnorr signature (BIP-340)
      final signature = privateKey.schnorrSign(message);

      return signature;
    } catch (e) {
      throw Exception('Failed to sign message: $e');
    }
  }

  /// Verify a BIP-340 Schnorr signature
  static bool verify(
      Uint8List signature, Uint8List message, Uint8List publicKey) {
    if (signature.length != 64) return false;
    if (message.length != 32) return false;
    if (publicKey.length != 32) return false;

    try {
      // Create x-only public key from bytes
      final pubKey = ECPublic.fromXOnlyBytes(publicKey);

      // Verify the Schnorr signature
      return pubKey.verifySchnorr(message, signature);
    } catch (e) {
      print('Verification error: $e');
      return false;
    }
  }

  /// Helper function to convert hex string to bytes
  static Uint8List hexToBytes(String hex) {
    if (hex.length % 2 != 0) {
      hex = '0$hex';
    }
    return Uint8List.fromList(List.generate(hex.length ~/ 2,
        (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16)));
  }

  /// Helper function to convert bytes to hex string
  static String bytesToHex(Uint8List bytes) {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }
}
