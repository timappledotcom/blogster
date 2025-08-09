import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class UbuntuAboutDialog extends StatelessWidget {
  const UbuntuAboutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final accentColor = themeProvider.accentColor.getColor(isDark);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ubuntu-style header with logo
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
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
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.edit_note,
                    size: 24,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Blogster',
                      style: TextStyle(
                        fontFamily: 'Ubuntu',
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : const Color(0xFF1D1D1D),
                      ),
                    ),
                    Text(
                      'Powered by Ubuntu Design',
                      style: TextStyle(
                        fontFamily: 'Ubuntu',
                        fontSize: 14,
                        color: accentColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Features list with Ubuntu styling
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF1D1D1D) : const Color(0xFFF6F6F6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Design Philosophy',
                    style: TextStyle(
                      fontFamily: 'Ubuntu',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : const Color(0xFF1D1D1D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._buildFeatureList(isDark),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Ubuntu-style action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: accentColor,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.w500,
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

  List<Widget> _buildFeatureList(bool isDark) {
    final features = [
      'Clean, minimalist Ubuntu design language',
      'Customizable Ubuntu accent colors',
      'Ubuntu font family for consistent typography',
      'Yaru-inspired component styling',
      'Accessible color contrasts and spacing',
    ];

    return features
        .map((feature) => Builder(
              builder: (context) {
                final accentColor = Provider.of<ThemeProvider>(context)
                    .accentColor
                    .getColor(isDark);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.only(top: 8, right: 12),
                        decoration: BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          feature,
                          style: TextStyle(
                            fontFamily: 'Ubuntu',
                            fontSize: 14,
                            color:
                                isDark ? Colors.white70 : Colors.grey.shade700,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ))
        .toList();
  }
}
