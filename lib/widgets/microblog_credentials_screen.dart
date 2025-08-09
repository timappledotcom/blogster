import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/microblog_credentials_provider.dart';
import '../services/microblog_service.dart';

class MicroblogCredentialsScreen extends StatefulWidget {
  const MicroblogCredentialsScreen({super.key});

  @override
  State<MicroblogCredentialsScreen> createState() =>
      _MicroblogCredentialsScreenState();
}

class _MicroblogCredentialsScreenState
    extends State<MicroblogCredentialsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MicroblogCredentialsProvider>().loadCredentials();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Micro.blog Credentials'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCredentialDialog(context),
            tooltip: 'Add Credential',
          ),
        ],
      ),
      body: Consumer<MicroblogCredentialsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
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
                    'Error: ${provider.error}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
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

          if (provider.credentials.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_circle_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Micro.blog credentials found',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first credential to start publishing to Micro.blog',
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
              final isDefault = provider.currentCredential?.id == credential.id;

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isDefault
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.web,
                      color: isDefault
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  title: Text(credential.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(credential.blogUrl),
                      if (isDefault)
                        Text(
                          'Default',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) => _handleMenuAction(
                      context,
                      value,
                      credential,
                      provider,
                    ),
                    itemBuilder: (context) => [
                      if (!isDefault)
                        const PopupMenuItem(
                          value: 'set_default',
                          child: ListTile(
                            leading: Icon(Icons.star),
                            title: Text('Set as Default'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Edit Name'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'export',
                        child: ListTile(
                          leading: Icon(Icons.download),
                          title: Text('Export Token'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete),
                          title: Text('Delete'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _handleMenuAction(
    BuildContext context,
    String action,
    MicroblogCredential credential,
    MicroblogCredentialsProvider provider,
  ) {
    switch (action) {
      case 'set_default':
        provider.setCurrentCredential(credential.id);
        break;
      case 'edit':
        _showEditNameDialog(context, credential, provider);
        break;
      case 'export':
        _exportCredential(context, credential, provider);
        break;
      case 'delete':
        _showDeleteConfirmation(context, credential, provider);
        break;
    }
  }

  void _showAddCredentialDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _AddCredentialDialog(),
    );
  }

  void _showEditNameDialog(
    BuildContext context,
    MicroblogCredential credential,
    MicroblogCredentialsProvider provider,
  ) {
    final controller = TextEditingController(text: credential.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Credential Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != credential.name) {
                try {
                  await provider.updateCredentialName(credential.id, newName);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Credential name updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update name: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } else {
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _exportCredential(
    BuildContext context,
    MicroblogCredential credential,
    MicroblogCredentialsProvider provider,
  ) async {
    final token = await provider.exportCredential(credential.id);
    if (token != null && context.mounted) {
      await Clipboard.setData(ClipboardData(text: token));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('App token copied to clipboard'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    MicroblogCredential credential,
    MicroblogCredentialsProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Credential'),
        content: Text(
          'Are you sure you want to delete "${credential.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await provider.deleteCredential(credential.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Credential deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete credential: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _AddCredentialDialog extends StatefulWidget {
  const _AddCredentialDialog();

  @override
  State<_AddCredentialDialog> createState() => _AddCredentialDialogState();
}

class _AddCredentialDialogState extends State<_AddCredentialDialog> {
  final _nameController = TextEditingController();
  final _tokenController = TextEditingController();
  final _urlController = TextEditingController();
  bool _setAsDefault = false;
  bool _isLoading = false;
  bool _isTestingConnection = false;

  @override
  void dispose() {
    _nameController.dispose();
    _tokenController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Micro.blog Credential'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'My Blog',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _tokenController,
              decoration: const InputDecoration(
                labelText: 'App Token',
                hintText: 'Your Micro.blog app token',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Blog URL',
                hintText: 'https://yourblog.micro.blog',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _setAsDefault,
                  onChanged: (value) {
                    setState(() {
                      _setAsDefault = value ?? false;
                    });
                  },
                ),
                const Text('Set as default'),
                const Spacer(),
                TextButton.icon(
                  onPressed: _isTestingConnection ? null : _testConnection,
                  icon: _isTestingConnection
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle),
                  label: const Text('Test'),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ||
                  _nameController.text.trim().isEmpty ||
                  _tokenController.text.trim().isEmpty
              ? null
              : _addCredential,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add'),
        ),
      ],
    );
  }

  Future<void> _testConnection() async {
    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an app token first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isTestingConnection = true;
    });

    try {
      final microblogService = MicroblogService();
      final result = await microblogService.testConnection(token);

      if (context.mounted) {
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Connection successful!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Connection failed: ${result['error']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Test failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTestingConnection = false;
        });
      }
    }
  }

  Future<void> _addCredential() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = context.read<MicroblogCredentialsProvider>();
      await provider.addCredential(
        name: _nameController.text.trim(),
        appToken: _tokenController.text.trim(),
        blogUrl: _urlController.text.trim().isEmpty
            ? 'https://micro.blog'
            : _urlController.text.trim(),
        setAsDefault: _setAsDefault,
      );

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Credential added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add credential: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
