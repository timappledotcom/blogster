import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/editor_provider.dart';
import '../providers/microblog_credentials_provider.dart';
import '../widgets/image_picker_widget.dart';
import '../widgets/spellcheck_widget.dart';

class EditorToolbar extends StatelessWidget {
  const EditorToolbar({super.key});

  void _showImagePicker(BuildContext context) {
    final microblogProvider =
        Provider.of<MicroblogCredentialsProvider>(context, listen: false);
    final editorProvider = Provider.of<EditorProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: ImagePickerWidget(
            onImageInserted: (markdown) {
              // Insert the markdown at the current cursor position
              final currentContent = editorProvider.content;
              final newContent = '$currentContent\n\n$markdown\n\n';
              editorProvider.updateContent(newContent);
            },
            microblogToken: microblogProvider.currentCredential?.appToken,
            showMicroblogOption: microblogProvider.hasCredentials,
          ),
        ),
      ),
    );
  }

  void _showSpellcheck(BuildContext context) {
    final editorProvider = Provider.of<EditorProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SpellcheckWidget(
          text: editorProvider.content,
          onTextChanged: (newText) {
            editorProvider.updateContent(newText);
          },
          onClose: () => Navigator.pop(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Consumer<EditorProvider>(
            builder: (context, provider, child) {
              return SegmentedButton<ViewMode>(
                segments: const [
                  ButtonSegment(
                    value: ViewMode.edit,
                    label: Text('Edit'),
                    icon: Icon(Icons.edit_outlined, size: 18),
                  ),
                  ButtonSegment(
                    value: ViewMode.preview,
                    label: Text('Preview'),
                    icon: Icon(Icons.visibility_outlined, size: 18),
                  ),
                  ButtonSegment(
                    value: ViewMode.split,
                    label: Text('Split'),
                    icon: Icon(Icons.view_column_outlined, size: 18),
                  ),
                ],
                selected: {provider.viewMode},
                onSelectionChanged: (Set<ViewMode> selection) {
                  provider.setViewMode(selection.first);
                },
                style: ButtonStyle(
                  textStyle: WidgetStateProperty.all(
                    Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          // Image insertion button
          IconButton(
            onPressed: () => _showImagePicker(context),
            icon: const Icon(Icons.image_outlined),
            tooltip: 'Insert Image',
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withOpacity(0.5),
            ),
          ),
          const SizedBox(width: 8),
          // Spellcheck button
          IconButton(
            onPressed: () => _showSpellcheck(context),
            icon: const Icon(Icons.spellcheck_outlined),
            tooltip: 'Spell Check',
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withOpacity(0.5),
            ),
          ),
          const Spacer(),
          Consumer<EditorProvider>(
            builder: (context, provider, child) {
              final fileName =
                  provider.currentFilePath?.split('/').last ?? 'Untitled';
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      provider.currentFilePath != null
                          ? Icons.description_outlined
                          : Icons.edit_note_outlined,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      fileName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
