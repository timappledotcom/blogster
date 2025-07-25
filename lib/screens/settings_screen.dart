import 'package:flutter/material.dart';
import 'settings/appearance_settings_screen.dart';
import 'settings/help_settings_screen.dart';
import 'settings/about_settings_screen.dart';
import 'settings/support_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingsItem(
            context,
            icon: Icons.palette,
            title: 'Appearance',
            subtitle: 'Theme and display preferences',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AppearanceSettingsScreen(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildSettingsItem(
            context,
            icon: Icons.help_outline,
            title: 'Help & Guide',
            subtitle: 'Tips and keyboard shortcuts',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const HelpSettingsScreen(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildSettingsItem(
            context,
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'Version info and technical details',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AboutSettingsScreen(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildSettingsItem(
            context,
            icon: Icons.favorite,
            title: 'Support the Project',
            subtitle: 'Tips and project information',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const SupportSettingsScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
