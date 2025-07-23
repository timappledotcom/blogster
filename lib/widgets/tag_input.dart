import 'package:flutter/material.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tag input field
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: widget.hint ?? 'Add tags (press Enter)',
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
    return Chip(
      label: Text(
        '#$tag',
        style: const TextStyle(fontSize: 12),
      ),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: () => widget.onTagRemove(tag),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }
}
