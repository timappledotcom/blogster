# Complete BIP-340 Schnorr Signature Implementation for Nostr Applications

This is a comprehensive guide and implementation for adding proper Nostr support to Flutter/Dart applications. Use this template whenever creating a new Nostr app.

## Overview

Nostr (Notes and Other Stuff Transmitted by Relays) requires **BIP-340 Schnorr signatures** for event authentication. This implementation provides:

- ✅ BIP-340 compliant Schnorr signatures
- ✅ X-only public key generation
- ✅ Proper event ID generation (SHA256 of canonical JSON)
- ✅ Long-form content support (NIP-23)
- ✅ WebSocket relay communication
- ✅ Tagged hash functions per BIP-340

## Quick Setup

### 1. Add Dependencies

```yaml
dependencies:
  # Core cryptography
  crypto: ^3.0.3
  pointycastle: ^3.9.1

  # WebSocket communication
  web_socket_channel: ^2.4.0

  # Bech32 encoding for nsec keys
  bech32: ^0.2.2

  # JSON handling
  convert: ^3.1.1
```

### 2. Copy the BIP-340 Implementation

Copy the `CorrectedBIP340Schnorr` class from `lib/crypto/corrected_bip340_schnorr.dart` to your project.

### 3. Copy the Nostr Service

Copy the `NostrService` class from `lib/services/nostr_service.dart` to your project.

### 4. Usage Example

```dart
import 'package:your_app/services/nostr_service.dart';

void main() async {
  final nostrService = NostrService();

  const privateKey = 'your_hex_private_key_here'; // 64 hex characters
  const content = 'Hello Nostr!';
  const relays = [
    'wss://relay.nostr.band',
    'wss://nostr.wine',
    'wss://relay.snort.social',
  ];

  // Publish a simple note
  await nostrService.publishNote(
    content: content,
    privateKey: privateKey,
    relays: relays,
  );

  // Publish long-form content (NIP-23)
  await nostrService.publishNote(
    content: content,
    privateKey: privateKey,
    relays: relays,
    title: 'My Blog Post', // Adding title makes it long-form
  );
}
```

## Key Implementation Details

### BIP-340 Compliance

The implementation follows BIP-340 exactly:

1. **X-only public keys**: 32-byte x-coordinates only
2. **Even y-coordinates**: Negate nonce if R.y is odd
3. **Tagged hashes**: Use proper BIP-340 tagged hash construction
4. **Deterministic nonces**: RFC 6979 style nonce generation

### Event Structure

Events follow NIP-01 and NIP-23 specifications:

```dart
{
  "id": "event_id_hex",           // SHA256 of canonical JSON
  "pubkey": "xonly_pubkey_hex",   // 32-byte x-only public key
  "created_at": timestamp,        // Unix timestamp
  "kind": 1,                      // 1 = note, 30023 = long-form
  "tags": [...],                  // Event tags
  "content": "...",               // Event content
  "sig": "signature_hex"          // 64-byte BIP-340 signature
}
```

### Long-form Content (NIP-23)

For blog posts and articles:

- **Kind**: 30023 (replaceable event)
- **Tags**: Must include `d` tag with unique identifier first
- **Required tags**: `title`, `published_at`, topic tags (`t`)

### Common Pitfalls Avoided

1. **Signature verification failures**: Uses proper BIP-340 algorithms
2. **Event ID mismatches**: Canonical JSON serialization
3. **Public key format errors**: Correct x-only key generation
4. **Tag ordering issues**: `d` tag first for replaceable events
5. **WebSocket timeout handling**: Proper connection management

## File Structure

```
lib/
├── crypto/
│   └── corrected_bip340_schnorr.dart    # BIP-340 implementation
├── services/
│   └── nostr_service.dart               # Main Nostr functionality
└── widgets/
    └── nostr_publish_dialog.dart        # UI for publishing
```

## Testing

Include comprehensive tests:

```dart
// Test BIP-340 compliance
dart test_bip340.dart

// Test event generation
dart test_nostr.dart

// Test relay responses
dart test_comprehensive_nostr.dart
```

## Relay Compatibility

Tested with major Nostr relays:

- ✅ relay.nostr.band
- ✅ nostr.wine
- ✅ relay.snort.social
- ✅ nos.lol
- ✅ relay.current.fyi

## Security Considerations

1. **Private key handling**: Never log or store private keys
2. **Random number generation**: Use secure randomness for production
3. **Key validation**: Always validate private key ranges
4. **Error handling**: Graceful failure modes

## Extensions

Easy to extend for additional NIPs:

- **NIP-04**: Encrypted direct messages
- **NIP-05**: DNS-based identity verification
- **NIP-19**: Bech32-encoded entities
- **NIP-42**: Authentication to relays

## Troubleshooting

### "invalid: bad signature"
- Check BIP-340 compliance
- Verify event ID generation
- Ensure proper nonce handling

### "invalid: bad event"
- Validate JSON structure
- Check tag ordering (d tag first)
- Verify required fields

### Connection timeouts
- Check relay URLs
- Implement retry logic
- Handle WebSocket errors

## Production Readiness

For production use:

1. Add proper error handling and logging
2. Implement connection pooling
3. Add retry mechanisms for failed publishes
4. Cache successful publishes
5. Implement proper key management
6. Add rate limiting

---

**This implementation is battle-tested and Nostr-compliant. Use it as your foundation for any Nostr application.**

## Prompt for Future Use

When creating a new Nostr application, use this prompt:

> "I need to implement Nostr publishing in my Flutter/Dart app. Please implement a complete BIP-340 compliant Schnorr signature system with proper event generation, x-only public keys, tagged hashes, and relay communication. Include support for both simple notes (kind 1) and long-form content (kind 30023, NIP-23). The implementation should handle WebSocket connections to multiple relays and provide proper error handling. Base it on the battle-tested implementation that includes CorrectedBIP340Schnorr class and NostrService class with comprehensive testing."
