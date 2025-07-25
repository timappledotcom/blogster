import 'package:flutter/material.dart';

class HelpSettingsScreen extends StatelessWidget {
  const HelpSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Guide'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHelpItem(
            context,
            'Getting Started',
            'Create your first document by clicking the New button in the library sidebar. Documents are automatically saved as you type.',
            Icons.rocket_launch,
          ),
          const SizedBox(height: 12),
          _buildHelpItem(
            context,
            'Library Management',
            'Your documents are stored in ~/Documents/blogster by default. Use the sidebar to browse, search, and organize your drafts and published posts.',
            Icons.folder,
          ),
          const SizedBox(height: 12),
          _buildHelpItem(
            context,
            'Markdown Support',
            'Write using standard Markdown syntax. Use # for headers, **bold**, *italic*, and ``` for code blocks. Switch to Preview mode to see formatted output.',
            Icons.text_fields,
          ),
          const SizedBox(height: 12),
          _buildHelpItem(
            context,
            'Nostr Publishing',
            'Share your content on the decentralized web! Click the share button to publish to Nostr relays. Configure your private key in the Nostr settings.',
            Icons.share,
          ),
          const SizedBox(height: 12),
          _buildHelpItem(
            context,
            'Auto-Save',
            'Documents are automatically saved every 2 seconds after you stop typing. No need to manually save - just focus on writing!',
            Icons.save,
          ),
          const SizedBox(height: 12),
          _buildHelpItem(
            context,
            'Keyboard Shortcuts',
            'Ctrl+N: New document\nCtrl+O: Open file\nCtrl+S: Save as\nCtrl+Shift+P: Publish to Nostr',
            Icons.keyboard,
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.tips_and_updates,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Pro Tips',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '💡 Use the sidebar collapse button to maximize your writing space',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '💡 Documents are sorted by last modified, so your most recent work is always at the top',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '💡 Use Split view mode to see your markdown and preview side-by-side',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '💡 Search documents by title or filename using the search bar in the sidebar',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(
      BuildContext context, String title, String description, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withOpacity(0.7),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
