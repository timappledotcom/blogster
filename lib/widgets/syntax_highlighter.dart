import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/vs2015.dart';

class CodeHighlighter extends StatelessWidget {
  final String code;
  final String? language;
  final bool isDarkMode;

  const CodeHighlighter({
    super.key,
    required this.code,
    this.language,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the language for highlighting
    String highlightLanguage = _normalizeLanguage(language);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF0D1117)
            : const Color(0xFFF6F8FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (language != null && language!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                language!,
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'JetBrains Mono',
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          HighlightView(
            code,
            language: highlightLanguage,
            theme: isDarkMode ? vs2015Theme : githubTheme,
            padding: EdgeInsets.zero,
            textStyle: const TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  String _normalizeLanguage(String? lang) {
    if (lang == null || lang.isEmpty) return 'plaintext';

    // Map common language aliases to highlight.js language names
    final languageMap = {
      'js': 'javascript',
      'ts': 'typescript',
      'jsx': 'javascript',
      'tsx': 'typescript',
      'py': 'python',
      'rb': 'ruby',
      'sh': 'bash',
      'shell': 'bash',
      'yml': 'yaml',
      'md': 'markdown',
      'kt': 'kotlin',
      'cs': 'csharp',
      'cpp': 'cpp',
      'c++': 'cpp',
      'hpp': 'cpp',
      'h': 'c',
      'rs': 'rust',
      'go': 'go',
      'php': 'php',
      'swift': 'swift',
      'scala': 'scala',
      'r': 'r',
      'sql': 'sql',
      'xml': 'xml',
      'html': 'xml',
      'css': 'css',
      'scss': 'scss',
      'sass': 'scss',
      'less': 'less',
      'json': 'json',
      'yaml': 'yaml',
      'toml': 'toml',
      'ini': 'ini',
      'dockerfile': 'dockerfile',
      'makefile': 'makefile',
      'gradle': 'gradle',
      'dart': 'dart',
      'flutter': 'dart',
    };

    return languageMap[lang.toLowerCase()] ?? lang.toLowerCase();
  }
}