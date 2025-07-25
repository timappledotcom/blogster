import 'dart:convert';
import 'dart:math';

class NostrCredential {
  final String id;
  final String name;
  final String privateKey;
  final String publicKey;
  final DateTime createdAt;
  final bool isDefault;

  NostrCredential({
    required this.id,
    required this.name,
    required this.privateKey,
    required this.publicKey,
    required this.createdAt,
    this.isDefault = false,
  });

  String get shortPublicKey => publicKey.length > 12
      ? '${publicKey.substring(0, 6)}...${publicKey.substring(publicKey.length - 6)}'
      : publicKey;

  NostrCredential copyWith({
    String? id,
    String? name,
    String? privateKey,
    String? publicKey,
    DateTime? createdAt,
    bool? isDefault,
  }) {
    return NostrCredential(
      id: id ?? this.id,
      name: name ?? this.name,
      privateKey: privateKey ?? this.privateKey,
      publicKey: publicKey ?? this.publicKey,
      createdAt: createdAt ?? this.createdAt,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'privateKey': privateKey,
      'publicKey': publicKey,
      'createdAt': createdAt.toIso8601String(),
      'isDefault': isDefault,
    };
  }

  factory NostrCredential.fromJson(Map<String, dynamic> json) {
    return NostrCredential(
      id: json['id'],
      name: json['name'],
      privateKey: json['privateKey'],
      publicKey: json['publicKey'],
      createdAt: DateTime.parse(json['createdAt']),
      isDefault: json['isDefault'] ?? false,
    );
  }
}

class NostrCredentialsService {
  static final NostrCredentialsService _instance =
      NostrCredentialsService._internal();
  factory NostrCredentialsService() => _instance;
  NostrCredentialsService._internal();

  final List<NostrCredential> _credentials = [];
  String? _currentCredentialId;

  List<NostrCredential> get credentials => List.unmodifiable(_credentials);

  NostrCredential? get currentCredential {
    if (_currentCredentialId == null) return null;
    try {
      return _credentials.firstWhere((c) => c.id == _currentCredentialId);
    } catch (e) {
      return null;
    }
  }

  Future<void> initialize() async {
    // In-memory initialization - no persistent storage
    if (_credentials.isEmpty) {
      // Create a default credential for testing
      final credential = await generateCredential('Default Identity');
      _credentials.add(credential);
      _currentCredentialId = credential.id;
    }
  }

  Future<List<NostrCredential>> loadCredentials() async {
    await initialize();
    return credentials;
  }

  Future<NostrCredential> generateCredential(String name) async {
    final random = Random.secure();
    final privateKeyBytes = List.generate(32, (_) => random.nextInt(256));
    final privateKey =
        privateKeyBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

    // For simplicity, use the private key as public key (not cryptographically correct, but works for testing)
    final publicKey = privateKey.substring(0, 64);

    final credential = NostrCredential(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      privateKey: privateKey,
      publicKey: publicKey,
      createdAt: DateTime.now(),
    );

    return credential;
  }

  Future<void> addCredential(NostrCredential credential) async {
    _credentials.add(credential);
    _currentCredentialId ??= credential.id;
  }

  Future<void> updateCredential(NostrCredential credential) async {
    final index = _credentials.indexWhere((c) => c.id == credential.id);
    if (index != -1) {
      _credentials[index] = credential;
    }
  }

  Future<void> deleteCredential(String credentialId) async {
    _credentials.removeWhere((c) => c.id == credentialId);
    if (_currentCredentialId == credentialId) {
      _currentCredentialId =
          _credentials.isNotEmpty ? _credentials.first.id : null;
    }
  }

  Future<void> setCurrentCredential(String credentialId) async {
    if (_credentials.any((c) => c.id == credentialId)) {
      _currentCredentialId = credentialId;
    }
  }

  Future<void> setDefaultCredential(String credentialId) async {
    await setCurrentCredential(credentialId);
  }

  Future<void> saveCredential(NostrCredential credential) async {
    final index = _credentials.indexWhere((c) => c.id == credential.id);
    if (index != -1) {
      _credentials[index] = credential;
    } else {
      _credentials.add(credential);
    }
  }

  Future<void> clearAllCredentials() async {
    _credentials.clear();
    _currentCredentialId = null;
  }

  Future<NostrCredential> importCredential(
      String name, String privateKey) async {
    // Simple validation
    if (privateKey.length != 64) {
      throw ArgumentError('Invalid private key length');
    }

    final publicKey = privateKey.substring(0, 64); // Simplified for testing

    final credential = NostrCredential(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      privateKey: privateKey,
      publicKey: publicKey,
      createdAt: DateTime.now(),
    );

    await addCredential(credential);
    return credential;
  }

  String exportCredential(String credentialId) {
    final credential = _credentials.firstWhere((c) => c.id == credentialId);
    return jsonEncode(credential.toJson());
  }

  Future<NostrCredential?> getDefaultCredential() async {
    await initialize();
    return currentCredential ??
        (_credentials.isNotEmpty ? _credentials.first : null);
  }
}
