import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/editor_provider.dart';
import '../providers/nostr_credentials_provider.dart';
import '../providers/library_provider.dart';
import '../screens/nostr_credentials_screen.dart';
import 'tag_input.dart';

class NostrPublishDialog extends StatefulWidget {
  const NostrPublishDialog({super.key});

  @override
  State<NostrPublishDialog> createState() => _NostrPublishDialogState();
}

class _NostrPublishDialogState extends State<NostrPublishDialog> {
  final _titleController = TextEditingController();
  final _relaysController = TextEditingController(
    text: 'wss://relay.damus.io,wss://nos.lol,wss://relay.snort.social',
  );

  @override
  void dispose() {
    _titleController.dispose();
    _relaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<EditorProvider, NostrCredentialsProvider, LibraryProvider>(
      builder: (context, editorProvider, credentialsProvider, libraryProvider,
          child) {
        // If no credentials are available, show setup message
        if (credentialsProvider.credentials.isEmpty) {
          return AlertDialog(
            title: const Text('No Credentials'),
            content: const Text(
              'No Nostr credentials found. Please set up your credentials first.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NostrCredentialsScreen(),
                    ),
                  );
                },
                child: const Text('Set Up Credentials'),
              ),
            ],
          );
        }

        return AlertDialog(
          title: const Text('Publish to Nostr'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Credential Selection
                if (credentialsProvider.credentials.length > 1) ...[
                  const Text(
                    'Select Identity:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: credentialsProvider.currentCredential?.id,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: credentialsProvider.credentials.map((credential) {
                      return DropdownMenuItem(
                        value: credential.id,
                        child: Text(credential.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        credentialsProvider.setCurrentCredential(value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  Text(
                    'Publishing as: ${credentialsProvider.currentCredential?.name ?? 'Unknown'}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                ],

                // Title Field
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Relays Field
                TextField(
                  controller: _relaysController,
                  decoration: const InputDecoration(
                    labelText: 'Relays (comma-separated)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Tags Input
                const Text(
                  'Tags:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TagInput(
                  tags: editorProvider.tags,
                  onTagAdd: editorProvider.addTag,
                  onTagRemove: editorProvider.removeTag,
                  hint: 'Add tags (e.g. flutter, dart, blog)',
                ),
                const SizedBox(height: 16),

                // Credentials Management Button
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const NostrCredentialsScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.settings),
                        label: const Text('Manage Credentials'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: editorProvider.isLoading
                  ? null
                  : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: editorProvider.isLoading ||
                      credentialsProvider.currentCredential == null
                  ? null
                  : () => _publishNote(context, editorProvider,
                      credentialsProvider, libraryProvider),
              child: editorProvider.isLoading
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

  Future<void> _publishNote(
    BuildContext context,
    EditorProvider editorProvider,
    NostrCredentialsProvider credentialsProvider,
    LibraryProvider libraryProvider,
  ) async {
    final credential = credentialsProvider.currentCredential;
    if (credential == null) return;

    final title = _titleController.text.trim();
    final relaysText = _relaysController.text.trim();
    final relays = relaysText
        .split(',')
        .map((r) => r.trim())
        .where((r) => r.isNotEmpty)
        .toList();

    if (relays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter at least one relay')),
      );
      return;
    }

    try {
      // Use the legacy method for backwards compatibility
      await editorProvider.publishToNostr(
        privateKey: credential.privateKey,
        relays: relays,
        title: title.isEmpty ? null : title,
      );

      // Mark the current document as posted if it exists
      if (libraryProvider.currentDocument != null) {
        await libraryProvider
            .markDocumentAsPosted(libraryProvider.currentDocument!.id);
      }

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Successfully published to Nostr and moved to posted folder!'),
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
    }
  }
}
