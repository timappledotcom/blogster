import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/editor_provider.dart';
import '../providers/nostr_credentials_provider.dart';
import '../providers/microblog_credentials_provider.dart';
import '../providers/library_provider.dart';
import '../services/nostr_service.dart';
import '../services/microblog_service.dart';
import '../screens/nostr_credentials_screen.dart';
import '../widgets/microblog_credentials_screen.dart';
import 'category_selector.dart';

enum PublishPlatform { nostr, microblog, both }

class PublishDialog extends StatefulWidget {
  const PublishDialog({super.key});

  @override
  State<PublishDialog> createState() => _PublishDialogState();
}

class _PublishDialogState extends State<PublishDialog> {
  final _relaysController = TextEditingController(
    text: 'wss://relay.damus.io,wss://nos.lol,wss://relay.snort.social',
  );

  PublishPlatform _selectedPlatform = PublishPlatform.nostr;
  bool _isPublishing = false;

  // Micro.blog category management
  List<String> _availableCategories = [];
  List<String> _selectedCategories = [];
  bool _isLoadingCategories = false;
  String? _categoriesError;

  @override
  void dispose() {
    _relaysController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Initialize selected categories with current tags
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final editorProvider =
          Provider.of<EditorProvider>(context, listen: false);
      setState(() {
        _selectedCategories = List<String>.from(editorProvider.tags);
      });
    });
  }

  /// Load categories from Micro.blog
  Future<void> _loadMicroblogCategories(
      MicroblogCredentialsProvider microblogProvider) async {
    final credential = microblogProvider.currentCredential;
    if (credential == null) return;

    setState(() {
      _isLoadingCategories = true;
      _categoriesError = null;
    });

    try {
      final microblogService = MicroblogService();
      final result = await microblogService.getCategories(credential.appToken);

      if (result['success']) {
        setState(() {
          _availableCategories = List<String>.from(result['categories']);
          _isLoadingCategories = false;
        });
      } else {
        setState(() {
          _categoriesError = result['error'] ?? 'Failed to load categories';
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      setState(() {
        _categoriesError = 'Error loading categories: $e';
        _isLoadingCategories = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer4<EditorProvider, NostrCredentialsProvider,
        MicroblogCredentialsProvider, LibraryProvider>(
      builder: (context, editorProvider, nostrProvider, microblogProvider,
          libraryProvider, child) {
        return AlertDialog(
          title: const Text('Publish Post'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Platform Selection
                const Text(
                  'Platform:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<PublishPlatform>(
                            title: const Text('Nostr'),
                            value: PublishPlatform.nostr,
                            groupValue: _selectedPlatform,
                            onChanged: (value) {
                              setState(() {
                                _selectedPlatform = value!;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<PublishPlatform>(
                            title: const Text('Micro.blog'),
                            value: PublishPlatform.microblog,
                            groupValue: _selectedPlatform,
                            onChanged: (value) {
                              setState(() {
                                _selectedPlatform = value!;
                              });
                              // Load categories when switching to Micro.blog
                              if (value == PublishPlatform.microblog) {
                                _loadMicroblogCategories(microblogProvider);
                              }
                            },
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                    // Both platforms option
                    RadioListTile<PublishPlatform>(
                      title: const Text('Both Platforms'),
                      subtitle: const Text(
                          'Publish to Nostr and Micro.blog simultaneously'),
                      value: PublishPlatform.both,
                      groupValue: _selectedPlatform,
                      onChanged: (value) {
                        setState(() {
                          _selectedPlatform = value!;
                        });
                        // Load categories when switching to both (includes Micro.blog)
                        if (value == PublishPlatform.both) {
                          _loadMicroblogCategories(microblogProvider);
                        }
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Platform-specific content
                if (_selectedPlatform == PublishPlatform.nostr)
                  _buildNostrContent(nostrProvider)
                else if (_selectedPlatform == PublishPlatform.microblog)
                  _buildMicroblogContent(microblogProvider)
                else
                  _buildBothPlatformsContent(nostrProvider, microblogProvider),

                const SizedBox(height: 16),

                // Platform-specific fields
                if (_selectedPlatform == PublishPlatform.nostr) ...[
                  TextField(
                    controller: _relaysController,
                    decoration: const InputDecoration(
                      labelText: 'Relays (comma-separated)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isPublishing ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _isPublishing ||
                      !_canPublish(nostrProvider, microblogProvider)
                  ? null
                  : () => _publishPost(context, editorProvider, nostrProvider,
                      microblogProvider, libraryProvider),
              child: _isPublishing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Publish'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNostrContent(NostrCredentialsProvider nostrProvider) {
    if (nostrProvider.credentials.isEmpty) {
      return _buildNoCredentialsMessage(
        'No Nostr credentials found. Please set up your credentials first.',
        () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const NostrCredentialsScreen()),
        ),
      );
    }

    return _buildCredentialSelection(
      credentials: nostrProvider.credentials
          .map((c) => {'id': c.id, 'name': c.name})
          .toList(),
      currentCredentialId: nostrProvider.currentCredential?.id,
      onCredentialChanged: (id) => nostrProvider.setCurrentCredential(id),
      onManageCredentials: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NostrCredentialsScreen()),
      ),
    );
  }

  Widget _buildMicroblogContent(
      MicroblogCredentialsProvider microblogProvider) {
    if (microblogProvider.credentials.isEmpty) {
      return _buildNoCredentialsMessage(
        'No Micro.blog credentials found. Please set up your credentials first.',
        () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const MicroblogCredentialsScreen()),
        ),
      );
    }

    return Column(
      children: [
        _buildCredentialSelection(
          credentials: microblogProvider.credentials
              .map((c) => {'id': c.id, 'name': c.name})
              .toList(),
          currentCredentialId: microblogProvider.currentCredential?.id,
          onCredentialChanged: (id) {
            microblogProvider.setCurrentCredential(id);
            // Load categories when credential changes
            _loadMicroblogCategories(microblogProvider);
          },
          onManageCredentials: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const MicroblogCredentialsScreen()),
          ),
        ),
        const SizedBox(height: 16),
        // Category selector for Micro.blog
        CategorySelector(
          availableCategories: _availableCategories,
          selectedCategories: _selectedCategories,
          onCategoriesChanged: (categories) {
            setState(() {
              _selectedCategories = categories;
            });
          },
          isLoading: _isLoadingCategories,
          errorMessage: _categoriesError,
          onRefresh: () => _loadMicroblogCategories(microblogProvider),
        ),
      ],
    );
  }

  Widget _buildBothPlatformsContent(NostrCredentialsProvider nostrProvider,
      MicroblogCredentialsProvider microblogProvider) {
    final nostrMissing = nostrProvider.credentials.isEmpty;
    final microblogMissing = microblogProvider.credentials.isEmpty;

    if (nostrMissing && microblogMissing) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              'No credentials found for either platform. Please set up credentials for both Nostr and Micro.blog.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NostrCredentialsScreen()),
                    ),
                    child: const Text('Setup Nostr'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const MicroblogCredentialsScreen()),
                    ),
                    child: const Text('Setup Micro.blog'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nostr section
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.flash_on, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Nostr',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  if (nostrMissing)
                    Icon(
                      Icons.warning,
                      color: Theme.of(context).colorScheme.error,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (nostrMissing) ...[
                Text(
                  'No Nostr credentials found.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NostrCredentialsScreen()),
                  ),
                  child: const Text('Setup Nostr Credentials'),
                ),
              ] else ...[
                Text(
                  'Publishing as: ${nostrProvider.currentCredential?.name ?? 'Unknown'}',
                  style: const TextStyle(fontSize: 12),
                ),
                if (nostrProvider.credentials.length > 1) ...[
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: nostrProvider.currentCredential?.id,
                    decoration: const InputDecoration(
                      labelText: 'Nostr Identity',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: nostrProvider.credentials.map((credential) {
                      return DropdownMenuItem(
                        value: credential.id,
                        child: Text(credential.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        nostrProvider.setCurrentCredential(value);
                      }
                    },
                  ),
                ],
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Micro.blog section
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.web, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Micro.blog',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  if (microblogMissing)
                    Icon(
                      Icons.warning,
                      color: Theme.of(context).colorScheme.error,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (microblogMissing) ...[
                Text(
                  'No Micro.blog credentials found.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const MicroblogCredentialsScreen()),
                  ),
                  child: const Text('Setup Micro.blog Credentials'),
                ),
              ] else ...[
                Text(
                  'Publishing as: ${microblogProvider.currentCredential?.name ?? 'Unknown'}',
                  style: const TextStyle(fontSize: 12),
                ),
                if (microblogProvider.credentials.length > 1) ...[
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: microblogProvider.currentCredential?.id,
                    decoration: const InputDecoration(
                      labelText: 'Micro.blog Identity',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: microblogProvider.credentials.map((credential) {
                      return DropdownMenuItem(
                        value: credential.id,
                        child: Text(credential.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        microblogProvider.setCurrentCredential(value);
                        _loadMicroblogCategories(microblogProvider);
                      }
                    },
                  ),
                ],
                const SizedBox(height: 12),
                // Category selector for Micro.blog
                CategorySelector(
                  availableCategories: _availableCategories,
                  selectedCategories: _selectedCategories,
                  onCategoriesChanged: (categories) {
                    setState(() {
                      _selectedCategories = categories;
                    });
                  },
                  isLoading: _isLoadingCategories,
                  errorMessage: _categoriesError,
                  onRefresh: () => _loadMicroblogCategories(microblogProvider),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoCredentialsMessage(String message, VoidCallback onSetup) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            message,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: onSetup,
            child: const Text('Set Up Credentials'),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialSelection({
    required List<Map<String, String>> credentials,
    required String? currentCredentialId,
    required Function(String) onCredentialChanged,
    required VoidCallback onManageCredentials,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (credentials.length > 1) ...[
          const Text(
            'Select Identity:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: currentCredentialId,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: credentials.map((credential) {
              return DropdownMenuItem(
                value: credential['id'],
                child: Text(credential['name']!),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                onCredentialChanged(value);
              }
            },
          ),
        ] else ...[
          Text(
            'Publishing as: ${credentials.first['name']}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onManageCredentials,
            icon: const Icon(Icons.settings),
            label: const Text('Manage Credentials'),
          ),
        ),
      ],
    );
  }

  bool _canPublish(NostrCredentialsProvider nostrProvider,
      MicroblogCredentialsProvider microblogProvider) {
    if (_selectedPlatform == PublishPlatform.nostr) {
      return nostrProvider.currentCredential != null;
    } else if (_selectedPlatform == PublishPlatform.microblog) {
      return microblogProvider.currentCredential != null;
    } else {
      // both platforms
      return nostrProvider.currentCredential != null ||
          microblogProvider.currentCredential != null;
    }
  }

  Future<void> _publishPost(
    BuildContext context,
    EditorProvider editorProvider,
    NostrCredentialsProvider nostrProvider,
    MicroblogCredentialsProvider microblogProvider,
    LibraryProvider libraryProvider,
  ) async {
    setState(() {
      _isPublishing = true;
    });

    try {
      final title = editorProvider.title.trim();

      if (_selectedPlatform == PublishPlatform.nostr) {
        await _publishToNostr(editorProvider, nostrProvider, title);
      } else if (_selectedPlatform == PublishPlatform.microblog) {
        await _publishToMicroblog(editorProvider, microblogProvider, title);
      } else {
        // Publish to both platforms
        await _publishToBothPlatforms(
            editorProvider, nostrProvider, microblogProvider, title);
      }

      // Mark the current document as posted if it exists
      if (libraryProvider.currentDocument != null) {
        // Determine which platforms were published to
        final publishedPlatforms = <String>[];
        if (_selectedPlatform == PublishPlatform.nostr) {
          publishedPlatforms.add('Nostr');
        } else if (_selectedPlatform == PublishPlatform.microblog) {
          publishedPlatforms.add('Micro.blog');
        } else {
          // Both platforms - add based on available credentials
          if (nostrProvider.currentCredential != null) {
            publishedPlatforms.add('Nostr');
          }
          if (microblogProvider.currentCredential != null) {
            publishedPlatforms.add('Micro.blog');
          }
        }

        // Get the tags/categories used for publishing
        final tagsUsed = _selectedPlatform == PublishPlatform.microblog ||
                _selectedPlatform == PublishPlatform.both
            ? _selectedCategories // Use categories for Micro.blog
            : editorProvider.tags; // Use tags for Nostr

        await libraryProvider.markDocumentAsPosted(
          libraryProvider.currentDocument!.id,
          tags: tagsUsed,
          publishedPlatforms: publishedPlatforms,
        );
      }

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getSuccessMessage()),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to publish: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPublishing = false;
        });
      }
    }
  }

  String _getSuccessMessage() {
    switch (_selectedPlatform) {
      case PublishPlatform.nostr:
        return 'Successfully published to Nostr and moved to posted folder!';
      case PublishPlatform.microblog:
        return 'Successfully published to Micro.blog and moved to posted folder!';
      case PublishPlatform.both:
        return 'Successfully published to both Nostr and Micro.blog and moved to posted folder!';
    }
  }

  Future<void> _publishToBothPlatforms(
    EditorProvider editorProvider,
    NostrCredentialsProvider nostrProvider,
    MicroblogCredentialsProvider microblogProvider,
    String title,
  ) async {
    final List<String> errors = [];
    final List<String> successes = [];

    // Publish to Nostr (if credentials available)
    if (nostrProvider.currentCredential != null) {
      try {
        await _publishToNostr(editorProvider, nostrProvider, title);
        successes.add('Nostr');
      } catch (e) {
        errors.add('Nostr: $e');
      }
    }

    // Publish to Micro.blog (if credentials available)
    if (microblogProvider.currentCredential != null) {
      try {
        await _publishToMicroblog(editorProvider, microblogProvider, title);
        successes.add('Micro.blog');
      } catch (e) {
        errors.add('Micro.blog: $e');
      }
    }

    // Handle results
    if (errors.isNotEmpty && successes.isEmpty) {
      // All failed
      throw Exception(
          'Failed to publish to both platforms:\n${errors.join('\n')}');
    } else if (errors.isNotEmpty && successes.isNotEmpty) {
      // Partial success
      throw Exception(
          'Published to ${successes.join(', ')} but failed for:\n${errors.join('\n')}');
    } else if (successes.isEmpty) {
      // No credentials available
      throw Exception('No credentials available for either platform');
    }
    // All succeeded - no exception thrown
  }

  Future<void> _publishToNostr(
    EditorProvider editorProvider,
    NostrCredentialsProvider nostrProvider,
    String title,
  ) async {
    final credential = nostrProvider.currentCredential;
    if (credential == null) throw Exception('No Nostr credential selected');

    final relaysText = _relaysController.text.trim();
    final relays = relaysText
        .split(',')
        .map((r) => r.trim())
        .where((r) => r.isNotEmpty)
        .toList();

    if (relays.isEmpty) {
      throw Exception('Please enter at least one relay');
    }

    final nostrService = NostrService();
    await nostrService.publishNote(
      content: editorProvider.content,
      relays: relays,
      title: title.isEmpty ? null : title,
      tags: editorProvider.tags,
      credential: credential,
    );
  }

  Future<void> _publishToMicroblog(
    EditorProvider editorProvider,
    MicroblogCredentialsProvider microblogProvider,
    String title,
  ) async {
    final credential = microblogProvider.currentCredential;
    if (credential == null) {
      throw Exception('No Micro.blog credential selected');
    }

    final microblogService = MicroblogService();
    await microblogService.publishPost(
      content: editorProvider.content,
      appToken: credential.appToken,
      title: title.isEmpty ? null : title,
      categories: _selectedCategories,
    );
  }
}
