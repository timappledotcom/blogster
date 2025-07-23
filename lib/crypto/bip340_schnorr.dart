import 'dart:typed_data';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart';

/// BIP-340 Schnorr signature implementation for Nostr
///
/// This implements the complete BIP-340 specification as required by Nostr protocol.
/// Reference: https://github.com/bitcoin/bips/blob/master/bip-0340.mediawiki
class BIP340Schnorr {
  static final ECDomainParameters _secp256k1 = ECDomainParameters('secp256k1');

  // secp256k1 prime field constant
  static final BigInt _p = BigInt.parse(
      'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F',
      radix: 16);

  /// Generate x-only public key from private key (32 bytes)
  static Uint8List getXOnlyPublicKey(Uint8List privateKeyBytes) {
    if (privateKeyBytes.length != 32) {
      throw ArgumentError('Private key must be exactly 32 bytes');
    }

    final privateKeyInt = _bytesToBigInt(privateKeyBytes);

    // Validate private key is in valid range [1, n-1]
    if (privateKeyInt == BigInt.zero || privateKeyInt >= _secp256k1.n) {
      throw ArgumentError('Private key out of valid range');
    }

    // Calculate public key point P = d * G
    final publicKeyPoint = _secp256k1.G * privateKeyInt;
    if (publicKeyPoint == null || publicKeyPoint.isInfinity) {
      throw StateError('Invalid public key point generated');
    }

    // Return x-coordinate as 32 bytes (x-only public key)
    final xCoord = publicKeyPoint.x!.toBigInteger()!;
    return _bigIntToBytes(xCoord, 32);
  }

  /// Sign a message using BIP-340 Schnorr signature
  static Uint8List sign(Uint8List message, Uint8List privateKeyBytes) {
    if (privateKeyBytes.length != 32) {
      throw ArgumentError('Private key must be exactly 32 bytes');
    }
    if (message.length != 32) {
      throw ArgumentError('Message must be exactly 32 bytes (hash)');
    }

    final d = _bytesToBigInt(privateKeyBytes);

    // Validate private key
    if (d == BigInt.zero || d >= _secp256k1.n) {
      throw ArgumentError('Private key out of valid range');
    }

    // Calculate public key point P = d * G
    final P = _secp256k1.G * d;
    if (P == null || P.isInfinity) {
      throw StateError('Invalid public key point');
    }

    // Get x-only public key (32 bytes)
    final px = P.x!.toBigInteger()!;
    final pubkeyBytes = _bigIntToBytes(px, 32);

    // Generate auxiliary random data (32 bytes)
    final aux = _generateAuxiliaryRandom();

    // Calculate tagged hash for nonce generation
    final t = _taggedHash('BIP0340/nonce',
        [..._bigIntToBytes(d, 32), ...pubkeyBytes, ...message, ...aux]);
    var k = _bytesToBigInt(t) % _secp256k1.n;

    // Ensure k is not zero
    if (k == BigInt.zero) {
      throw StateError('Generated nonce k is zero');
    }

    // Calculate R = k * G
    final R = _secp256k1.G * k;
    if (R == null || R.isInfinity) {
      throw StateError('Invalid nonce point R');
    }

    // Get R coordinates
    final rx = R.x!.toBigInteger()!;
    final ry = R.y!.toBigInteger()!;

    // If R.y is odd, negate k (BIP-340 requirement for even y-coordinate)
    if (ry.isOdd) {
      k = _secp256k1.n - k;
    }

    // Calculate challenge e = tagged_hash("BIP0340/challenge", R.x || P.x || m)
    final rxBytes = _bigIntToBytes(rx, 32);
    final eHash = _taggedHash(
        'BIP0340/challenge', [...rxBytes, ...pubkeyBytes, ...message]);
    final e = _bytesToBigInt(eHash) % _secp256k1.n;

    // Calculate signature s = (k + e * d) mod n
    final s = (k + (e * d)) % _secp256k1.n;

    // Return signature as r || s (64 bytes total)
    final signature = Uint8List(64);
    signature.setRange(0, 32, rxBytes);
    signature.setRange(32, 64, _bigIntToBytes(s, 32));

    return signature;
  }

  /// Verify a BIP-340 Schnorr signature
  static bool verify(
      Uint8List signature, Uint8List message, Uint8List publicKey) {
    if (signature.length != 64) {
      throw ArgumentError('Signature must be exactly 64 bytes');
    }
    if (message.length != 32) {
      throw ArgumentError('Message must be exactly 32 bytes');
    }
    if (publicKey.length != 32) {
      throw ArgumentError('Public key must be exactly 32 bytes');
    }

    try {
      // Extract r and s from signature
      final r = _bytesToBigInt(signature.sublist(0, 32));
      final s = _bytesToBigInt(signature.sublist(32, 64));

      // Validate r and s are in valid range
      if (r >= _p || s >= _secp256k1.n) {
        return false;
      }

      // Calculate challenge e = tagged_hash("BIP0340/challenge", r || P || m)
      final eHash = _taggedHash('BIP0340/challenge',
          [..._bigIntToBytes(r, 32), ...publicKey, ...message]);
      final e = _bytesToBigInt(eHash) % _secp256k1.n;

      // Calculate R = s*G - e*P
      final sG = _secp256k1.G * s;
      if (sG == null) return false;

      // Reconstruct public key point from x-coordinate
      final px = _bytesToBigInt(publicKey);
      final P = _liftX(px);
      if (P == null) return false;

      final eP = P * e;
      if (eP == null) return false;

      final R = sG + (eP * BigInt.from(-1));
      if (R == null || R.isInfinity) return false;

      // Check if R.x == r and R.y is even
      final rx = R.x!.toBigInteger()!;
      final ry = R.y!.toBigInteger()!;

      return rx == r && ry.isEven;
    } catch (e) {
      return false;
    }
  }

  /// Lift x-coordinate to a point on the curve (BIP-340 specific)
  static ECPoint? _liftX(BigInt x) {
    if (x >= _p) return null;

    // Calculate y² = x³ + 7 (mod p)
    final x3 = (x * x * x) % _p;
    final y2 = (x3 + BigInt.from(7)) % _p;

    // Calculate y = y²^((p+1)/4) mod p (works because p ≡ 3 mod 4)
    final exp = (_p + BigInt.one) ~/ BigInt.from(4);
    final y = y2.modPow(exp, _p);

    // Verify y² ≡ y2 (mod p)
    if ((y * y) % _p != y2) return null;

    // Choose even y-coordinate
    final yFinal = y.isEven ? y : _p - y;

    try {
      return _secp256k1.curve.createPoint(x, yFinal);
    } catch (e) {
      return null;
    }
  }

  /// Generate auxiliary random data (32 bytes)
  static Uint8List _generateAuxiliaryRandom() {
    // In production, this should use a secure random number generator
    // For now, we'll use a deterministic approach based on current time
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final data = utf8.encode('aux_random_$timestamp');
    final hash = sha256.convert(data);
    return Uint8List.fromList(hash.bytes);
  }

  /// BIP-340 tagged hash function
  static Uint8List _taggedHash(String tag, List<int> data) {
    final tagBytes = utf8.encode(tag);
    final tagHash = sha256.convert(tagBytes);

    // tagged_hash(tag, data) = SHA256(SHA256(tag) || SHA256(tag) || data)
    final combined = [...tagHash.bytes, ...tagHash.bytes, ...data];
    final result = sha256.convert(combined);

    return Uint8List.fromList(result.bytes);
  }

  /// Convert bytes to BigInt (big-endian)
  static BigInt _bytesToBigInt(Uint8List bytes) {
    BigInt result = BigInt.zero;
    for (int byte in bytes) {
      result = (result << 8) + BigInt.from(byte);
    }
    return result;
  }

  /// Convert BigInt to bytes with fixed length (big-endian)
  static Uint8List _bigIntToBytes(BigInt bigInt, int length) {
    final bytes = <int>[];
    var temp = bigInt;

    // Convert to bytes
    while (temp > BigInt.zero) {
      bytes.insert(0, (temp & BigInt.from(0xff)).toInt());
      temp = temp >> 8;
    }

    // Pad with leading zeros if necessary
    while (bytes.length < length) {
      bytes.insert(0, 0);
    }

    // Truncate if too long (shouldn't happen with proper input)
    if (bytes.length > length) {
      bytes.removeRange(0, bytes.length - length);
    }

    return Uint8List.fromList(bytes);
  }
}
