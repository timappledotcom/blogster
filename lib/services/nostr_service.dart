import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../crypto/corrected_bip340_schnorr.dart';
import 'nostr_credentials_service_encrypted.dart';

class NostrService {
  /// Publish a note using a specific credential, or the default if none provided
  Future<void> publishNote({
    required String content,
    required List<String> relays,
    String? title,
    List<String>? tags,
    NostrCredential? credential,
  }) async {
    try {
      // Use provided credential or get default
      NostrCredential? cred = credential;
      if (cred == null) {
        final credentialsService = NostrCredentialsService();
        cred = await credentialsService.getDefaultCredential();
        if (cred == null) {
          throw Exception(
              'No Nostr credentials available. Please add a credential first.');
        }
      }

      // Convert hex private key to bytes (ensure 32 bytes)
      final privateKeyBytes = _hexToBytes(cred.privateKey);
      if (privateKeyBytes.length != 32) {
        throw Exception('Private key must be exactly 32 bytes');
      }

      // Generate event
      final event = await _createEvent(
        content: content,
        privateKeyBytes: privateKeyBytes,
        title: title,
        userTags: tags,
      );

      print('Generated Nostr event:');
      print('ID: ${event['id']}');
      print('PubKey: ${event['pubkey']}');
      print('Signature: ${event['sig']}');

      // Publish to relays asynchronously (truly fire and forget)
      for (final relay in relays) {
        // Don't await - let it run in background
        _publishToRelaySimple(relay, event);
      }

      // Return immediately - don't wait for any responses
      print('Publishing initiated to ${relays.length} relays');
    } catch (e) {
      print('Error in publishNote: $e');
      rethrow;
    }
  }

  /// Legacy method for backwards compatibility
  Future<void> publishNoteWithPrivateKey({
    required String content,
    required String privateKey,
    required List<String> relays,
    String? title,
    List<String>? tags,
  }) async {
    return publishNote(
      content: content,
      relays: relays,
      title: title,
      tags: tags,
      credential: NostrCredential(
        id: 'legacy',
        name: 'Legacy',
        privateKey: privateKey,
        publicKey: '', // Will be generated
        createdAt: DateTime.now(),
        isDefault: false,
      ),
    );
  }

  // Public method for testing
  Future<Map<String, dynamic>> createTestEvent({
    required String content,
    required String privateKey,
    int kind = 30023,
    List<List<String>>? tags,
  }) async {
    final privateKeyBytes = _hexToBytes(privateKey);
    if (privateKeyBytes.length != 32) {
      throw Exception('Private key must be exactly 32 bytes');
    }

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Default tags for testing
    final eventTags = tags ??
        [
          ['d', 'blogster-test-$now'],
          ['title', 'Test Post'],
          ['published_at', now.toString()],
          ['t', 'test'],
        ];

    return await _createEventWithCustomTags(
      content: content,
      privateKeyBytes: privateKeyBytes,
      kind: kind,
      tags: eventTags,
    );
  }

  Future<Map<String, dynamic>> _createEventWithCustomTags({
    required String content,
    required Uint8List privateKeyBytes,
    required int kind,
    required List<List<String>> tags,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Generate x-only public key from private key
    final publicKey = await _getXOnlyPublicKey(privateKeyBytes);

    // Create the event data array for ID generation (NIP-01 specification)
    final eventData = [
      0, // Reserved field
      publicKey, // Public key (hex string)
      now, // Created at timestamp
      kind, // Event kind
      tags, // Tags array
      content, // Content string
    ];

    // Generate event ID (SHA256 of canonical JSON)
    final eventId = _generateEventId(eventData);

    // Sign the event ID with BIP-340 Schnorr signature
    final signature = await _schnorrSign(eventId, privateKeyBytes);

    return {
      'id': eventId,
      'pubkey': publicKey,
      'created_at': now,
      'kind': kind,
      'tags': tags,
      'content': content,
      'sig': signature,
    };
  }

  Future<Map<String, dynamic>> _createEvent({
    required String content,
    required Uint8List privateKeyBytes,
    String? title,
    List<String>? userTags,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Generate x-only public key from private key
    final publicKey = await _getXOnlyPublicKey(privateKeyBytes);

    // Create tags for long-form content
    List<List<String>> tags = [];
    int kind = 1; // Default to note

    if (title != null && title.isNotEmpty) {
      kind = 30023; // Long-form content

      // Add a unique identifier for long-form content (required for replaceable events)
      // The 'd' tag should come first for replaceable events
      final identifier = 'blogster-${DateTime.now().millisecondsSinceEpoch}';
      tags.add(['d', identifier]);

      // Add other required tags for long-form content
      tags.add(['title', title]);
      tags.add(['published_at', now.toString()]);

      // Add topic tags
      tags.add(['t', 'blogster']);
      tags.add(['t', 'markdown']);
    }

    // Add user-provided tags
    if (userTags != null) {
      for (final userTag in userTags) {
        if (userTag.isNotEmpty) {
          tags.add(['t', userTag.toLowerCase()]);
        }
      }
    }

    // Create the event data array for ID generation (NIP-01 specification)
    final eventData = [
      0, // Reserved field
      publicKey, // Public key (hex string)
      now, // Created at timestamp
      kind, // Event kind
      tags, // Tags array
      content, // Content string
    ];

    // Generate event ID (SHA256 of canonical JSON)
    final eventId = _generateEventId(eventData);

    // Sign the event using Schnorr signature
    final signature = await _schnorrSign(eventId, privateKeyBytes);

    return {
      'id': eventId,
      'pubkey': publicKey,
      'created_at': now,
      'kind': kind,
      'tags': tags,
      'content': content,
      'sig': signature,
    };
  }

  Future<String> _getXOnlyPublicKey(Uint8List privateKeyBytes) async {
    try {
      // Use BIP-340 compliant x-only public key generation
      final xOnlyPubKey =
          CorrectedBIP340Schnorr.getXOnlyPublicKey(privateKeyBytes);
      return _bytesToHex(xOnlyPubKey);
    } catch (e) {
      print('Error generating x-only public key: $e');
      rethrow;
    }
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
    // Ensure consistent JSON encoding without spaces, following Nostr spec exactly
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
      // Use proper JSON string encoding
      return jsonEncode(data);
    } else if (data is int) {
      return data.toString();
    } else {
      return jsonEncode(data);
    }
  }

  Future<String> _schnorrSign(String eventId, Uint8List privateKeyBytes) async {
    try {
      // Use BIP-340 compliant Schnorr signature
      final eventIdBytes = _hexToBytes(eventId);
      final signature =
          CorrectedBIP340Schnorr.sign(eventIdBytes, privateKeyBytes);

      final sigHex = _bytesToHex(signature);
      print('Generated BIP-340 signature: $sigHex');

      return sigHex;
    } catch (e) {
      print('Error in BIP-340 signing: $e');
      rethrow;
    }
  }

  // Simple relay publishing that doesn't block
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
