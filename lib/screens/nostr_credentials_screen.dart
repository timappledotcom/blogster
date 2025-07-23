import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/nostr_credentials_provider.dart';
import '../services/nostr_credentials_service_encrypted.dart';
import '../utils/nostr_key_utils.dart';

class NostrCredentialsScreen extends StatefulWidget {
  const NostrCredentialsScreen({super.key});

  @override
  State<NostrCredentialsScreen> createState() => _NostrCredentialsScreenState();
}

class _NostrCredentialsScreenState extends State<NostrCredentialsScreen> {
  @override
  void initState() {
    super.initState();
    // Load credentials when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NostrCredentialsProvider>().loadCredentials();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nostr Credentials'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCredentialDialog(context),
            tooltip: 'Add New Credential',
          ),
        ],
      ),
      body: Consumer<NostrCredentialsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading credentials',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadCredentials(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!provider.hasCredentials) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.key_off,
                    size: 64,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Nostr Credentials',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first Nostr identity to start publishing',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddCredentialDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Credential'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.credentials.length,
            itemBuilder: (context, index) {
              final credential = provider.credentials[index];
              return _CredentialCard(
                credential: credential,
                isDefault: credential.isDefault,
                onSetDefault: credential.isDefault
                    ? null
                    : () => provider.setCurrentCredential(credential.id),
                onEdit: () => _showEditCredentialDialog(context, credential),
                onDelete: () => _showDeleteConfirmation(context, credential),
                onExport: () => _exportCredential(context, credential),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddCredentialDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _AddCredentialDialog(),
    );
  }

  void _showEditCredentialDialog(
      BuildContext context, NostrCredential credential) {
    showDialog(
      context: context,
      builder: (context) => _EditCredentialDialog(credential: credential),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, NostrCredential credential) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Credential'),
        content: Text(
          'Are you sure you want to delete "${credential.name}"?\n\n'
          'This action cannot be undone. Make sure you have backed up your private key if you want to use this identity again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              context
                  .read<NostrCredentialsProvider>()
                  .deleteCredential(credential.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportCredential(BuildContext context, NostrCredential credential) async {
    final privateKey = await context
        .read<NostrCredentialsProvider>()
        .exportCredential(credential.id);
    if (privateKey == null) return;

    String nsecKey;
    try {
      nsecKey = NostrKeyUtils.hexToNsec(privateKey);
    } catch (e) {
      nsecKey = 'Error converting to nsec format';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Private Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('⚠️ Keep this private key secure!'),
            const SizedBox(height: 16),
            const Text('Private Key (hex):'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                privateKey,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Private Key (nsec):'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                nsecKey,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          FilledButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: privateKey));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Hex private key copied to clipboard')),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy Hex'),
          ),
          FilledButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: nsecKey));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('nsec private key copied to clipboard')),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy nsec'),
          ),
        ],
      ),
    );
  }
}

class _CredentialCard extends StatelessWidget {
  final NostrCredential credential;
  final bool isDefault;
  final VoidCallback? onSetDefault;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onExport;

  const _CredentialCard({
    required this.credential,
    required this.isDefault,
    required this.onSetDefault,
    required this.onEdit,
    required this.onDelete,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            credential.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (isDefault) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'DEFAULT',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Public Key: ${credential.shortPublicKey}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Created: ${_formatDate(credential.createdAt)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'set_default':
                        onSetDefault?.call();
                        break;
                      case 'edit':
                        onEdit();
                        break;
                      case 'export':
                        onExport();
                        break;
                      case 'delete':
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    if (onSetDefault != null)
                      const PopupMenuItem(
                        value: 'set_default',
                        child: Row(
                          children: [
                            Icon(Icons.star),
                            SizedBox(width: 8),
                            Text('Set as Default'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Edit Name'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'export',
                      child: Row(
                        children: [
                          Icon(Icons.download),
                          SizedBox(width: 8),
                          Text('Export Key'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _AddCredentialDialog extends StatefulWidget {
  const _AddCredentialDialog();

  @override
  State<_AddCredentialDialog> createState() => _AddCredentialDialogState();
}

class _AddCredentialDialogState extends State<_AddCredentialDialog> {
  final _nameController = TextEditingController();
  final _privateKeyController = TextEditingController();
  final _hexController = TextEditingController();
  bool _isImport = false;
  String _keyFormat = 'hex'; // 'hex' or 'nsec'
  String? _conversionError;

  @override
  void initState() {
    super.initState();
    // Listen for changes in private key input to auto-convert
    _privateKeyController.addListener(_onPrivateKeyChanged);
    _hexController.addListener(_onHexKeyChanged);
  }

  void _onPrivateKeyChanged() {
    if (!_isImport) return;

    final text = _privateKeyController.text.trim();
    if (text.isEmpty) {
      _hexController.clear();
      setState(() => _conversionError = null);
      return;
    }

    if (_keyFormat == 'nsec') {
      try {
        final hexKey = NostrKeyUtils.nsecToHex(text);
        _hexController.text = hexKey;
        setState(() => _conversionError = null);
      } catch (e) {
        setState(() => _conversionError = 'Invalid nsec format');
      }
    } else {
      // For hex format, just validate and copy to hex controller
      if (text.length == 64 && RegExp(r'^[0-9a-fA-F]+$').hasMatch(text)) {
        _hexController.text = text.toLowerCase();
        setState(() => _conversionError = null);
      } else {
        setState(() =>
            _conversionError = 'Invalid hex format (must be 64 characters)');
      }
    }
  }

  void _onHexKeyChanged() {
    if (!_isImport || _keyFormat != 'hex') return;

    final text = _hexController.text.trim();
    if (text.isEmpty) {
      _privateKeyController.clear();
      return;
    }

    // Update the private key field when hex changes (for hex format)
    if (_privateKeyController.text != text) {
      _privateKeyController.text = text;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _privateKeyController.dispose();
    _hexController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isImport ? 'Import Credential' : 'Generate New Credential'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'My Nostr Identity',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() {
                    _isImport = false;
                    _privateKeyController.clear();
                    _hexController.clear();
                    _conversionError = null;
                  }),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: !_isImport
                        ? Theme.of(context).colorScheme.primaryContainer
                        : null,
                  ),
                  child: const Text('Generate'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() {
                    _isImport = true;
                    _conversionError = null;
                  }),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: _isImport
                        ? Theme.of(context).colorScheme.primaryContainer
                        : null,
                  ),
                  child: const Text('Import'),
                ),
              ),
            ],
          ),
          if (_isImport) ...[
            const SizedBox(height: 16),
            // Format selector
            Row(
              children: [
                const Text('Key Format: '),
                const SizedBox(width: 8),
                Expanded(
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'hex', label: Text('Hex')),
                      ButtonSegment(value: 'nsec', label: Text('nsec')),
                    ],
                    selected: {_keyFormat},
                    onSelectionChanged: (Set<String> selected) {
                      setState(() {
                        _keyFormat = selected.first;
                        _privateKeyController.clear();
                        _hexController.clear();
                        _conversionError = null;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Private key input
            TextField(
              controller: _privateKeyController,
              decoration: InputDecoration(
                labelText:
                    _keyFormat == 'nsec' ? 'nsec key' : 'Private Key (hex)',
                hintText: _keyFormat == 'nsec'
                    ? 'nsec1...'
                    : '64 character hex string',
                errorText: _conversionError,
              ),
              maxLines: _keyFormat == 'nsec' ? 2 : 1,
            ),
            if (_keyFormat == 'nsec') ...[
              const SizedBox(height: 12),
              TextField(
                controller: _hexController,
                decoration: const InputDecoration(
                  labelText: 'Converted Hex Key',
                  hintText: 'Auto-filled from nsec conversion',
                ),
                readOnly: true,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _canSubmit() ? _submit : null,
          child: Text(_isImport ? 'Import' : 'Generate'),
        ),
      ],
    );
  }

  bool _canSubmit() {
    if (_nameController.text.trim().isEmpty) return false;
    if (_isImport) {
      if (_privateKeyController.text.trim().isEmpty) return false;
      if (_conversionError != null) return false;
      // For nsec format, also check that hex conversion worked
      if (_keyFormat == 'nsec' && _hexController.text.trim().isEmpty)
        return false;
    }
    return true;
  }

  void _submit() async {
    final provider = context.read<NostrCredentialsProvider>();
    final name = _nameController.text.trim();

    if (await provider.isNameTaken(name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name already exists')),
      );
      return;
    }

    Navigator.of(context).pop();

    if (_isImport) {
      // Use the hex key for import (either directly entered or converted from nsec)
      final hexKey = _keyFormat == 'nsec'
          ? _hexController.text.trim()
          : _privateKeyController.text.trim();
      await provider.importCredential(
        name,
        hexKey,
        setAsDefault: !provider.hasCredentials,
      );
    } else {
      await provider.generateCredential(
        name,
        setAsDefault: !provider.hasCredentials,
      );
    }

    if (provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error!)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '${_isImport ? 'Imported' : 'Generated'} credential "$name"')),
      );
    }
  }
}

class _EditCredentialDialog extends StatefulWidget {
  final NostrCredential credential;

  const _EditCredentialDialog({required this.credential});

  @override
  State<_EditCredentialDialog> createState() => _EditCredentialDialogState();
}

class _EditCredentialDialogState extends State<_EditCredentialDialog> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.credential.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Credential'),
      content: TextField(
        controller: _nameController,
        decoration: const InputDecoration(
          labelText: 'Name',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _canSubmit() ? _submit : null,
          child: const Text('Save'),
        ),
      ],
    );
  }

  bool _canSubmit() {
    final name = _nameController.text.trim();
    return name.isNotEmpty && name != widget.credential.name;
  }

  void _submit() async {
    final provider = context.read<NostrCredentialsProvider>();
    final name = _nameController.text.trim();

    if (await provider.isNameTaken(name, excludeId: widget.credential.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name already exists')),
      );
      return;
    }

    Navigator.of(context).pop();

    await provider.updateCredentialName(widget.credential.id, name);

    if (provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error!)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credential updated')),
      );
    }
  }
}
