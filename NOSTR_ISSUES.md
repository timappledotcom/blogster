# Nostr Implementation Issues Found

## Current Problems

After testing with multiple Nostr relays, I've identified the following issues:

### 1. **Signature Issues** (Primary Problem)
- **Error**: `invalid: bad signature` from most relays
- **Cause**: The current Schnorr signature implementation is not BIP-340 compliant
- **Required**: Proper BIP-340 Schnorr signature with:
  - Correct challenge generation: `e = hash(R || P || m)` where R is the nonce point, P is the public key, m is the message
  - Proper nonce generation (RFC 6979 or similar)
  - x-only public key handling

### 2. **Event Structure Issues** (Secondary)
- **Error**: `invalid: bad event` from relay.nostr.band
- **Cause**: Some relays are stricter about event validation
- **Status**: Event structure looks mostly correct with proper tag ordering

### 3. **Current Implementation Status**
✅ **Working**:
- Event ID generation (SHA256 of canonical JSON)
- Tag structure for long-form content (NIP-23)
- WebSocket communication with relays
- Event structure (kind 30023, proper tags)

❌ **Broken**:
- Schnorr signature generation (not BIP-340 compliant)
- Public key derivation (may have issues)

## Recommended Solutions

### Option 1: Use a Proper Cryptographic Library
Add a dedicated Nostr/Bitcoin cryptography package:
```yaml
dependencies:
  secp256k1: ^0.3.0  # or similar BIP-340 implementation
```

### Option 2: Implement Proper BIP-340 Schnorr
Requires significant cryptographic implementation work.

### Option 3: Use External Tools
Validate the implementation by comparing with known-good Nostr tools.

## Test Results Summary

| Relay | Error | Issue |
|-------|-------|--------|
| relay.nostr.band | "invalid: bad event" | Event structure validation |
| nostr.wine | "invalid: bad signature" | Signature verification |
| relay.snort.social | "invalid: bad signature" | Signature verification |

The fact that 2/3 relays get to signature verification suggests the event structure is mostly correct.

## Next Steps

1. Fix the Schnorr signature implementation
2. Ensure proper x-only public key generation
3. Validate against the NIP-01 specification
4. Test with multiple relays for compatibility
