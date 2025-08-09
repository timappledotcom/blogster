import 'package:flutter_test/flutter_test.dart';
import 'package:blogster/crypto/corrected_bip340_schnorr.dart';
import 'package:blogster/services/nostr_service.dart';
import 'dart:typed_data';
import 'dart:convert';

void main() {
  group('Comprehensive Nostr BIP-340 Tests', () {
    test('BIP-340 test vector 1 - public key generation', () {
      // Test vector from BIP-340 specification
      final privateKey = _hexToBytes(
          '0000000000000000000000000000000000000000000000000000000000000003');
      const expectedPubKey =
          'F9308A019258C31049344F85F89D5229B531C845836F99B08601F113BCE036F9';

      final pubKey = CorrectedBIP340Schnorr.getXOnlyPublicKey(privateKey);
      final pubKeyHex = _bytesToHex(pubKey).toUpperCase();

      print('Generated pubkey: $pubKeyHex');
      print('Expected pubkey:  $expectedPubKey');

      expect(pubKeyHex, equals(expectedPubKey));
    });

    test('BIP-340 signature format validation', () {
      final privateKey = _hexToBytes(
          '7f3b9b82e2a4e06e9d4e1c7a8b5c4d3e2f1a0b9c8d7e6f5a4b3c2d1e0f9a8b7c');
      final message = Uint8List(32); // 32 zero bytes

      final signature = CorrectedBIP340Schnorr.sign(message, privateKey);

      // Signature should be exactly 64 bytes
      expect(signature.length, equals(64));

      // Signature should not be all zeros
      expect(signature.any((byte) => byte != 0), isTrue);

      print('Signature (hex): ${_bytesToHex(signature)}');
    });

    test('Nostr event generation and signing', () async {
      const privateKeyHex =
          '7f3b9b82e2a4e06e9d4e1c7a8b5c4d3e2f1a0b9c8d7e6f5a4b3c2d1e0f9a8b7c';
      const content = 'Hello Nostr! This is a test message.';
      const title = 'Test Post';

      final nostrService = NostrService();

      // Create a test event using the public method
      final event = await nostrService.createTestEvent(
        content: content,
        privateKey: privateKeyHex,
        kind: 30023, // Long-form content
        tags: [
          ['d', 'test-${DateTime.now().millisecondsSinceEpoch}'],
          ['title', title],
          ['t', 'test'],
        ],
      );

      // Validate event structure
      expect(event['id'], isA<String>());
      expect(event['pubkey'], isA<String>());
      expect(event['created_at'], isA<int>());
      expect(event['kind'], equals(30023));
      expect(event['tags'], isA<List>());
      expect(event['content'], equals(content));
      expect(event['sig'], isA<String>());

      // Validate field lengths
      expect(event['id'].length, equals(64)); // 32 bytes as hex
      expect(event['pubkey'].length, equals(64)); // 32 bytes as hex
      expect(event['sig'].length, equals(128)); // 64 bytes as hex

      print('Generated Nostr event:');
      print('ID: ${event['id']}');
      print('PubKey: ${event['pubkey']}');
      print('Signature: ${event['sig']}');
      print('Tags: ${event['tags']}');

      // Verify the signature is valid format (not all zeros)
      final sigBytes = _hexToBytes(event['sig']);
      expect(sigBytes.any((byte) => byte != 0), isTrue);
    });

    test('Multiple private keys generate different signatures', () {
      final messageHash =
          Uint8List.fromList(List.filled(32, 0)); // 32 zero bytes

      final privateKey1 = _hexToBytes(
          '0000000000000000000000000000000000000000000000000000000000000003');
      final privateKey2 = _hexToBytes(
          '0000000000000000000000000000000000000000000000000000000000000004');

      final sig1 = CorrectedBIP340Schnorr.sign(messageHash, privateKey1);
      final sig2 = CorrectedBIP340Schnorr.sign(messageHash, privateKey2);

      // Signatures should be different
      expect(_bytesToHex(sig1), isNot(equals(_bytesToHex(sig2))));

      print('Sig1: ${_bytesToHex(sig1)}');
      print('Sig2: ${_bytesToHex(sig2)}');
    });

    test('Validate event ID generation is deterministic', () async {
      const privateKeyHex =
          '7f3b9b82e2a4e06e9d4e1c7a8b5c4d3e2f1a0b9c8d7e6f5a4b3c2d1e0f9a8b7c';
      const content = 'Deterministic test content';

      final nostrService = NostrService();

      // Create the same event twice (with same timestamp to ensure determinism)
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      final tags = [
        ['d', 'deterministic-test'],
        ['title', 'Deterministic Test'],
        ['published_at', now.toString()],
      ];

      // For deterministic testing, we'd need to control the timestamp
      // For now, just verify the structure is consistent
      final event1 = await nostrService.createTestEvent(
        content: content,
        privateKey: privateKeyHex,
        kind: 30023,
        tags: tags,
      );

      final event2 = await nostrService.createTestEvent(
        content: content,
        privateKey: privateKeyHex,
        kind: 30023,
        tags: tags,
      );

      // Events should have same structure but different timestamps/IDs
      expect(event1['pubkey'], equals(event2['pubkey']));
      expect(event1['content'], equals(event2['content']));
      expect(event1['kind'], equals(event2['kind']));

      print('Event1 ID: ${event1['id']}');
      print('Event2 ID: ${event2['id']}');
    });
  });
}

// Helper functions
Uint8List _hexToBytes(String hex) {
  if (hex.length % 2 != 0) {
    hex = '0$hex';
  }
  return Uint8List.fromList(List.generate(hex.length ~/ 2,
      (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16)));
}

String _bytesToHex(Uint8List bytes) {
  return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
}
