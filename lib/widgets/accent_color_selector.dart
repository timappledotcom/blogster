import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class AccentColorSelector extends StatelessWidget {
  const AccentColorSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Accent Color',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Choose your preferred accent color for highlights, buttons, and interactive elements.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Ubuntu',
                    color: isDark ? Colors.white70 : Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: UbuntuAccentColor.values.map((color) {
                final isSelected = themeProvider.accentColor == color;
                return _AccentColorTile(
                  color: color,
                  isSelected: isSelected,
                  isDark: isDark,
                  onTap: () => themeProvider.setAccentColor(color),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

class _AccentColorTile extends StatelessWidget {
  final UbuntuAccentColor color;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _AccentColorTile({
    required this.color,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = color.getColor(isDark);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? accentColor
                : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Color preview circle
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      color: _getContrastColor(accentColor),
                      size: 24,
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            // Color name
            Text(
              color.name,
              style: TextStyle(
                fontFamily: 'Ubuntu',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: isDark ? Colors.white : const Color(0xFF1D1D1D),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            // Color description
            Text(
              color.description,
              style: TextStyle(
                fontFamily: 'Ubuntu',
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            // Sample elements preview
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Sample button
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Button',
                    style: TextStyle(
                      fontFamily: 'Ubuntu',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: _getContrastColor(accentColor),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Sample tag
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: accentColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '#tag',
                    style: TextStyle(
                      fontFamily: 'Ubuntu',
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getContrastColor(Color color) {
    // Calculate relative luminance
    final luminance =
        (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
