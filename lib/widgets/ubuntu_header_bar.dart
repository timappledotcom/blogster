import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/editor_provider.dart';
import '../providers/theme_provider.dart';

class UbuntuHeaderBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isMobile;
  final VoidCallback onPublish;
  final VoidCallback onSettings;

  const UbuntuHeaderBar({
    super.key,
    required this.isMobile,
    required this.onPublish,
    required this.onSettings,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              // Ubuntu-style hamburger menu for mobile
              if (isMobile)
                _UbuntuMenuButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),

              // App title with Ubuntu branding
              const SizedBox(width: 16),
              _UbuntuLogo(),
              const SizedBox(width: 8),
              Text(
                'Blogster',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontFamily: 'Ubuntu',
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : const Color(0xFF1D1D1D),
                ),
              ),

              const Spacer(),

              // Ubuntu-style action buttons
              _UbuntuActionButtons(
                onPublish: onPublish,
                onSettings: onSettings,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UbuntuMenuButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _UbuntuMenuButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(
            Icons.menu,
            size: 20,
            color: isDark ? Colors.white : const Color(0xFF1D1D1D),
          ),
        ),
      ),
    );
  }
}

class _UbuntuLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final accentColor = themeProvider.accentColor
        .getColor(Theme.of(context).brightness == Brightness.dark);

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor,
            Color.lerp(accentColor, Colors.black, 0.2)!,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.edit_note,
        size: 14,
        color: Colors.white,
      ),
    );
  }
}

class _UbuntuActionButtons extends StatelessWidget {
  final VoidCallback onPublish;
  final VoidCallback onSettings;

  const _UbuntuActionButtons({
    required this.onPublish,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<EditorProvider>(
      builder: (context, provider, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _UbuntuIconButton(
              icon: Icons.add,
              tooltip: 'New Document',
              onPressed: provider.newFile,
            ),
            const SizedBox(width: 4),
            _UbuntuIconButton(
              icon: Icons.folder_open_outlined,
              tooltip: 'Open Document',
              onPressed: provider.openFile,
            ),
            const SizedBox(width: 4),
            _UbuntuIconButton(
              icon: Icons.save_alt_outlined,
              tooltip: 'Save As',
              onPressed: provider.saveAsFile,
            ),
            const SizedBox(width: 12),
            // Primary action button - Ubuntu Orange
            _UbuntuPrimaryButton(
              icon: Icons.share,
              label: 'Publish',
              onPressed: onPublish,
            ),
            const SizedBox(width: 8),
            _UbuntuIconButton(
              icon: Icons.settings_outlined,
              tooltip: 'Settings',
              onPressed: onSettings,
            ),
          ],
        );
      },
    );
  }
}

class _UbuntuIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _UbuntuIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              size: 18,
              color: isDark ? Colors.white70 : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }
}

class _UbuntuPrimaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _UbuntuPrimaryButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final accentColor = themeProvider.accentColor
        .getColor(Theme.of(context).brightness == Brightness.dark);

    return Tooltip(
      message: 'Publish to Nostr or Micro.blog',
      child: Material(
        color: accentColor,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
