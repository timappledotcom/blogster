import 'package:flutter/material.dart';

class CategorySelector extends StatefulWidget {
  final List<String> availableCategories;
  final List<String> selectedCategories;
  final Function(List<String>) onCategoriesChanged;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRefresh;

  const CategorySelector({
    super.key,
    required this.availableCategories,
    required this.selectedCategories,
    required this.onCategoriesChanged,
    this.isLoading = false,
    this.errorMessage,
    this.onRefresh,
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  final TextEditingController _customCategoryController =
      TextEditingController();
  bool _showCustomInput = false;

  @override
  void dispose() {
    _customCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with refresh button
        Row(
          children: [
            const Text(
              'Categories:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            if (widget.onRefresh != null)
              IconButton(
                icon: widget.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh, size: 20),
                onPressed: widget.isLoading ? null : widget.onRefresh,
                tooltip: 'Refresh categories',
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Error message
        if (widget.errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning,
                  size: 16,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Available categories (if any)
        if (widget.availableCategories.isNotEmpty) ...[
          const Text(
            'Available categories:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Container(
            constraints: const BoxConstraints(maxHeight: 120),
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: widget.availableCategories.map((category) {
                  final isSelected =
                      widget.selectedCategories.contains(category);
                  return FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      final newCategories =
                          List<String>.from(widget.selectedCategories);
                      if (selected) {
                        if (!newCategories.contains(category)) {
                          newCategories.add(category);
                        }
                      } else {
                        newCategories.remove(category);
                      }
                      widget.onCategoriesChanged(newCategories);
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Selected categories display
        if (widget.selectedCategories.isNotEmpty) ...[
          const Text(
            'Selected categories:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: widget.selectedCategories.map((category) {
              return Chip(
                label: Text(category),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  final newCategories =
                      List<String>.from(widget.selectedCategories);
                  newCategories.remove(category);
                  widget.onCategoriesChanged(newCategories);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],

        // Custom category input
        if (_showCustomInput) ...[
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customCategoryController,
                  decoration: const InputDecoration(
                    labelText: 'Custom category',
                    hintText: 'Enter category name',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: _addCustomCategory,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _addCustomCategory,
                tooltip: 'Add category',
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _showCustomInput = false;
                    _customCategoryController.clear();
                  });
                },
                tooltip: 'Cancel',
              ),
            ],
          ),
        ] else ...[
          // Add custom category button
          TextButton.icon(
            onPressed: () {
              setState(() {
                _showCustomInput = true;
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Add custom category'),
          ),
        ],
      ],
    );
  }

  void _addCustomCategory([String? value]) {
    final categoryName = (value ?? _customCategoryController.text).trim();
    if (categoryName.isNotEmpty) {
      final newCategories = List<String>.from(widget.selectedCategories);
      if (!newCategories.contains(categoryName)) {
        newCategories.add(categoryName);
        widget.onCategoriesChanged(newCategories);
      }
      _customCategoryController.clear();
      setState(() {
        _showCustomInput = false;
      });
    }
  }
}
