import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/editor_provider.dart';
import '../providers/theme_provider.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Consumer<EditorProvider>(
        builder: (context, provider, child) {
          final wordCount = _countWords(provider.content);
          final readingTime = _calculateReadingTime(wordCount);

          return Row(
            children: [
              Icon(
                Icons.text_fields_outlined,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                '$wordCount words',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'Ubuntu',
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.timer_outlined,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                '$readingTime min read',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'Ubuntu',
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const Spacer(),
              // Ubuntu design indicator
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  final accentColor = themeProvider.accentColor.getColor(
                      Theme.of(context).brightness == Brightness.dark);

                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: accentColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: accentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Ubuntu Design',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontFamily: 'Ubuntu',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: accentColor,
                                  ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              Text(
                'Last edited: ${_getFormattedTime()}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'Ubuntu',
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          );
        },
      ),
    );
  }

  int _countWords(String text) {
    // Remove markdown syntax
    final cleanText = text
        .replaceAll(RegExp(r'```[\s\S]*?```'), '') // Remove code blocks
        .replaceAll(RegExp(r'`[^`]*`'), '') // Remove inline code
        .replaceAll(RegExp(r'!\[.*?\]\(.*?\)'), '') // Remove images
        .replaceAll(RegExp(r'\[.*?\]\(.*?\)'), '') // Remove links
        .replaceAll(RegExp(r'#{1,6}\s.*'), '') // Remove headings
        .replaceAll(
            RegExp(r'[*_~]{1,3}'), '') // Remove bold/italic/strikethrough
        .trim();

    // Count words
    if (cleanText.isEmpty) return 0;
    return cleanText.split(RegExp(r'\s+')).length;
  }

  int _calculateReadingTime(int wordCount) {
    // Average reading speed: 200 words per minute
    final minutes = (wordCount / 200).ceil();
    return minutes > 0 ? minutes : 1; // Minimum 1 minute
  }

  String _getFormattedTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}
