import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ImprovedNostrService {
  Future<void> publishNote({
    required String content,
    required String privateKey,
    required List<String> relays,
    String? title,
  }) async {
    try {
      // Convert hex private key to bytes
      final privateKeyBytes = _hexToBytes(privateKey);
      if (privateKeyBytes.length != 32) {
        throw Exception('Private key must be exactly 32 bytes');
      }

      // Generate event using proper BIP-340 cryptography
      final event = await _createEventWithProperCrypto(
        content: content,
        privateKeyBytes: privateKeyBytes,
        title: title,
      );

      print('Generated Nostr event with proper crypto:');
      print('ID: ${event['id']}');
      print('PubKey: ${event['pubkey']}');
      print('Signature: ${event['sig']}');

      // Publish to relays
      for (final relay in relays) {
        _publishToRelaySimple(relay, event);
      }

      print('Publishing initiated to ${relays.length} relays');
    } catch (e) {
      print('Error in publishNote: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _createEventWithProperCrypto({
    required String content,
    required Uint8List privateKeyBytes,
    String? title,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Generate proper secp256k1 key pair using bitcoin_base
    final privKey = ECPrivate.fromBytes(privateKeyBytes);
    final pubKey = privKey.getPublic();

    // Get x-only public key (32 bytes) for Nostr
    final xOnlyPubKey = pubKey.compressed.sublist(1); // Remove prefix byte
    final publicKeyHex = _bytesToHex(xOnlyPubKey);

    // Create tags for long-form content
    List<List<String>> tags = [];
    int kind = 1; // Default to note

    if (title != null && title.isNotEmpty) {
      kind = 30023; // Long-form content

      // Add identifier first (required for replaceable events)
      final identifier = 'blogster-${DateTime.now().millisecondsSinceEpoch}';
      tags.add(['d', identifier]);

      // Add other tags
      tags.add(['title', title]);
      tags.add(['published_at', now.toString()]);
      tags.add(['t', 'blogster']);
      tags.add(['t', 'markdown']);
    }

    // Create the event data array for ID generation (NIP-01 specification)
    final eventData = [
      0, // Reserved field
      publicKeyHex, // Public key (hex string)
      now, // Created at timestamp
      kind, // Event kind
      tags, // Tags array
      content, // Content string
    ];

    // Generate event ID (SHA256 of canonical JSON)
    final eventId = _generateEventId(eventData);

    // Create the complete event object
    final event = {
      'id': eventId,
      'pubkey': publicKeyHex,
      'created_at': now,
      'kind': kind,
      'tags': tags,
      'content': content,
    };

    // Sign the event using proper BIP-340 Schnorr signature
    final signature = _schnorrSignBIP340(eventId, privKey);
    event['sig'] = signature;

    return event;
  }

  String _generateEventId(List<dynamic> eventData) {
    // Create canonical JSON (no spaces, consistent ordering)
    final serialized = _canonicalJsonEncode(eventData);
    print('Event serialization for ID: $serialized');

    final bytes = utf8.encode(serialized);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  String _canonicalJsonEncode(dynamic data) {
    // Ensure consistent JSON encoding without spaces, following Nostr spec
    if (data is List) {
      final items = data.map((item) => _canonicalJsonEncode(item)).join(',');
      return '[$items]';
    } else if (data is Map) {
      final entries = <String>[];
      final sortedKeys = data.keys.cast<String>().toList()..sort();
      for (final key in sortedKeys) {
        final value = _canonicalJsonEncode(data[key]);
        entries.add('"$key":$value');
      }
      return '{${entries.join(',')}}';
    } else if (data is String) {
      return jsonEncode(data);
    } else if (data is int) {
      return data.toString();
    } else {
      return jsonEncode(data);
    }
  }

  String _schnorrSignBIP340(String eventId, ECPrivate privateKey) {
    try {
      // Convert event ID to bytes
      final messageBytes = _hexToBytes(eventId);

      // Use bitcoin_base for proper BIP-340 Schnorr signature
      final signature = privateKey.schnorrSign(messageBytes);

      return _bytesToHex(signature);
    } catch (e) {
      print('Error in BIP-340 signing: $e');
      rethrow;
    }
  }

  void _publishToRelaySimple(String relayUrl, Map<String, dynamic> event) {
    // Run in background without blocking
    () async {
      WebSocketChannel? channel;
      try {
        print('Connecting to relay: $relayUrl');
        final uri = Uri.parse(relayUrl);
        channel = WebSocketChannel.connect(uri);

        // Wait for connection with short timeout
        await channel.ready.timeout(const Duration(seconds: 3));

        // Send the event
        final message = jsonEncode(['EVENT', event]);
        channel.sink.add(message);

        print('Sent to $relayUrl');

        // Close after a short delay
        await Future.delayed(const Duration(seconds: 1));
      } catch (e) {
        print('Failed to publish to $relayUrl: $e');
      } finally {
        try {
          await channel?.sink.close();
        } catch (e) {
          // Ignore close errors
        }
      }
    }();
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
}
