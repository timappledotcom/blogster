import 'package:flutter_test/flutter_test.dart';
import 'package:blogster/utils/nostr_key_utils.dart';

void main() {
  group('NostrKeyUtils', () {
    test('should convert hex to nsec correctly', () {
      // Test with a valid hex private key
      const hexKey =
          'a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456';

      final nsecKey = NostrKeyUtils.hexToNsec(hexKey);

      expect(nsecKey, isNotNull);
      expect(nsecKey.startsWith('nsec'), isTrue);
    });

    test('should convert nsec to hex correctly', () {
      // Test conversion back
      const hexKey =
          'a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456';

      final nsecKey = NostrKeyUtils.hexToNsec(hexKey);
      final convertedHex = NostrKeyUtils.nsecToHex(nsecKey);

      expect(convertedHex.toLowerCase(), equals(hexKey.toLowerCase()));
    });

    test('should round-trip convert correctly', () {
      // Test round-trip conversion with various keys
      const testKeys = [
        'deadbeefcafebabe0123456789abcdef0123456789abcdef0123456789abcdef',
        '1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
        'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff',
        '0000000000000000000000000000000000000000000000000000000000000001',
      ];

      for (final hexKey in testKeys) {
        // Convert hex -> nsec -> hex
        final nsecKey = NostrKeyUtils.hexToNsec(hexKey);
        final convertedHex = NostrKeyUtils.nsecToHex(nsecKey);

        expect(convertedHex.toLowerCase(), equals(hexKey.toLowerCase()));
        expect(nsecKey.startsWith('nsec'), isTrue);
      }
    });

    test('should handle invalid nsec format gracefully', () {
      expect(() => NostrKeyUtils.nsecToHex('invalid'),
          throwsA(isA<ArgumentError>()));
      expect(() => NostrKeyUtils.nsecToHex('nsec1invalid'),
          throwsA(isA<ArgumentError>()));
    });

    test('should handle invalid hex format gracefully', () {
      expect(() => NostrKeyUtils.hexToNsec('invalid'),
          throwsA(isA<ArgumentError>()));
      expect(
          () => NostrKeyUtils.hexToNsec('zzzz'), throwsA(isA<ArgumentError>()));
    });
  });
}
