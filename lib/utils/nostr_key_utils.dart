import 'package:bech32/bech32.dart';
import 'package:convert/convert.dart';

class NostrKeyUtils {
  /// Convert hex private key to nsec format
  static String hexToNsec(String hexKey) {
    if (hexKey.length != 64) {
      throw ArgumentError('Hex key must be 64 characters long');
    }

    try {
      final bytes = hex.decode(hexKey);
      // Convert bytes to 5-bit groups for bech32
      final fiveBitData = _convertTo5BitGroups(bytes);
      final bech32Data = Bech32('nsec', fiveBitData);
      const codec = Bech32Codec();
      return codec.encode(bech32Data);
    } catch (e) {
      throw ArgumentError('Invalid hex key format: $e');
    }
  }

  /// Convert nsec format to hex private key
  static String nsecToHex(String nsecKey) {
    if (!nsecKey.startsWith('nsec1')) {
      throw ArgumentError('Invalid nsec format - must start with nsec1');
    }

    try {
      const codec = Bech32Codec();
      final decoded = codec.decode(nsecKey);

      if (decoded.hrp != 'nsec') {
        throw ArgumentError('Invalid nsec format - wrong human readable part');
      }

      // Convert 5-bit groups back to bytes
      final bytes = _convertFrom5BitGroups(decoded.data);
      if (bytes.length != 32) {
        throw ArgumentError('Invalid nsec format - wrong data length');
      }

      return hex.encode(bytes);
    } catch (e) {
      throw ArgumentError('Invalid nsec format: $e');
    }
  }

  /// Convert hex public key to npub format
  static String hexToNpub(String hexKey) {
    if (hexKey.length != 64) {
      throw ArgumentError('Hex key must be 64 characters long');
    }

    try {
      final bytes = hex.decode(hexKey);
      // Convert bytes to 5-bit groups for bech32
      final fiveBitData = _convertTo5BitGroups(bytes);
      final bech32Data = Bech32('npub', fiveBitData);
      const codec = Bech32Codec();
      return codec.encode(bech32Data);
    } catch (e) {
      throw ArgumentError('Invalid hex key format: $e');
    }
  }

  /// Convert npub format to hex public key
  static String npubToHex(String npubKey) {
    if (!npubKey.startsWith('npub1')) {
      throw ArgumentError('Invalid npub format - must start with npub1');
    }

    try {
      const codec = Bech32Codec();
      final decoded = codec.decode(npubKey);

      if (decoded.hrp != 'npub') {
        throw ArgumentError('Invalid npub format - wrong human readable part');
      }

      // Convert 5-bit groups back to bytes
      final bytes = _convertFrom5BitGroups(decoded.data);
      if (bytes.length != 32) {
        throw ArgumentError('Invalid npub format - wrong data length');
      }

      return hex.encode(bytes);
    } catch (e) {
      throw ArgumentError('Invalid npub format: $e');
    }
  }

  /// Convert 8-bit bytes to 5-bit groups for bech32
  static List<int> _convertTo5BitGroups(List<int> data) {
    final result = <int>[];
    int accumulator = 0;
    int bits = 0;

    for (final byte in data) {
      accumulator = (accumulator << 8) | byte;
      bits += 8;

      while (bits >= 5) {
        bits -= 5;
        result.add((accumulator >> bits) & 0x1f);
      }
    }

    if (bits > 0) {
      result.add((accumulator << (5 - bits)) & 0x1f);
    }

    return result;
  }

  /// Convert 5-bit groups back to 8-bit bytes
  static List<int> _convertFrom5BitGroups(List<int> data) {
    final result = <int>[];
    int accumulator = 0;
    int bits = 0;

    for (final value in data) {
      if (value < 0 || value > 31) {
        throw ArgumentError('Invalid 5-bit value: $value');
      }

      accumulator = (accumulator << 5) | value;
      bits += 5;

      while (bits >= 8) {
        bits -= 8;
        result.add((accumulator >> bits) & 0xff);
      }
    }

    if (bits >= 5) {
      throw ArgumentError('Invalid padding bits');
    }

    return result;
  }

  /// Validate hex key format
  static bool isValidHex(String key) {
    if (key.length != 64) return false;
    return RegExp(r'^[0-9a-fA-F]+$').hasMatch(key);
  }

  /// Validate nsec key format
  static bool isValidNsec(String key) {
    if (!key.startsWith('nsec1')) return false;
    try {
      nsecToHex(key);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Validate npub key format
  static bool isValidNpub(String key) {
    if (!key.startsWith('npub1')) return false;
    try {
      npubToHex(key);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Normalize private key from various formats to hex
  static String normalizePrivateKey(String key) {
    final trimmedKey = key.trim();

    if (isValidHex(trimmedKey)) {
      return trimmedKey.toLowerCase();
    } else if (isValidNsec(trimmedKey)) {
      return nsecToHex(trimmedKey);
    }

    throw ArgumentError('Invalid private key format');
  }

  /// Normalize public key from various formats to hex
  static String normalizePublicKey(String key) {
    final trimmedKey = key.trim();

    if (isValidHex(trimmedKey)) {
      return trimmedKey.toLowerCase();
    } else if (isValidNpub(trimmedKey)) {
      return npubToHex(trimmedKey);
    }

    throw ArgumentError('Invalid public key format');
  }
}
