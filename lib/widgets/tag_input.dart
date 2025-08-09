import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class TagInput extends StatefulWidget {
  final List<String> tags;
  final Function(String) onTagAdd;
  final Function(String) onTagRemove;
  final String? hint;

  const TagInput({
    super.key,
    required this.tags,
    required this.onTagAdd,
    required this.onTagRemove,
    this.hint,
  });

  @override
  State<TagInput> createState() => _TagInputState();
}

class _TagInputState extends State<TagInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addTag() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onTagAdd(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tag input field with Ubuntu styling
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          style: const TextStyle(
            fontFamily: 'Ubuntu',
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: widget.hint ?? 'Add tags (press Enter)',
            hintStyle: TextStyle(
              fontFamily: 'Ubuntu',
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            prefixIcon: Icon(
              Icons.tag,
              size: 18,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addTag,
            ),
          ),
          onSubmitted: (_) => _addTag(),
        ),

        // Tag chips
        if (widget.tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.tags.map((tag) => _buildTagChip(tag)).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildTagChip(String tag) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final accentColor = themeProvider.accentColor
        .getColor(Theme.of(context).brightness == Brightness.dark);

    return Container(
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '#$tag',
              style: TextStyle(
                fontFamily: 'Ubuntu',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: accentColor,
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => widget.onTagRemove(tag),
              child: Icon(
                Icons.close,
                size: 14,
                color: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
