import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'dart:async';
import '../providers/editor_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/library_provider.dart';
import '../providers/nostr_credentials_provider.dart';
import '../providers/microblog_credentials_provider.dart';
import '../widgets/toolbar.dart';
import '../widgets/status_bar.dart';
import '../widgets/publish_dialog.dart';
import '../widgets/syntax_highlighter.dart';
import '../widgets/library_sidebar.dart';
import '../widgets/tag_input.dart';
import '../widgets/ubuntu_header_bar.dart';
import 'settings_screen.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final ScrollController _editScrollController = ScrollController();
  final ScrollController _previewScrollController = ScrollController();
  Timer? _autoSaveTimer;
  bool _showTags = false;

  @override
  void initState() {
    super.initState();
    final editorProvider = Provider.of<EditorProvider>(context, listen: false);
    final libraryProvider =
        Provider.of<LibraryProvider>(context, listen: false);

    _controller.text = editorProvider.content;
    _titleController.text = editorProvider.title;

    _controller.addListener(() {
      editorProvider.updateContent(_controller.text);
      _startAutoSaveTimer();
    });

    _titleController.addListener(() {
      editorProvider.setTitle(_titleController.text);
      _startAutoSaveTimer();
    });

    // Listen to editor provider changes and update controller
    editorProvider.addListener(_updateControllerFromProvider);

    // Initialize library and credentials on startup
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await libraryProvider.initializeLibrary();
      // Auto-save the default content if library is empty
      if (libraryProvider.documents.isEmpty &&
          editorProvider.content.trim().isNotEmpty) {
        await libraryProvider.autoSave(editorProvider.content);
      }

      // Load saved credentials
      final nostrCredentialsProvider =
          Provider.of<NostrCredentialsProvider>(context, listen: false);
      final microblogCredentialsProvider =
          Provider.of<MicroblogCredentialsProvider>(context, listen: false);

      await nostrCredentialsProvider.loadCredentials();
      await microblogCredentialsProvider.loadCredentials();
    });
  }

  void _updateControllerFromProvider() {
    final editorProvider = Provider.of<EditorProvider>(context, listen: false);

    if (_controller.text != editorProvider.content) {
      _controller.text = editorProvider.content;
    }
    if (_titleController.text != editorProvider.title) {
      _titleController.text = editorProvider.title;
    }

    // Trigger auto-save for tag changes (since we can't directly detect tag changes)
    // We'll auto-save whenever the provider notifies, but with a timer to avoid too frequent saves
    _startAutoSaveTimer();
  }

  void _startAutoSaveTimer() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 2), () {
      _autoSave();
    });
  }

  Future<void> _autoSave() async {
    final libraryProvider = context.read<LibraryProvider>();
    final editorProvider = context.read<EditorProvider>();
    final content = _controller.text;

    if (content.trim().isNotEmpty) {
      // Get title and tags from EditorProvider and UI controllers
      final title = _titleController.text.trim().isNotEmpty 
          ? _titleController.text.trim() 
          : null;
      final tags = editorProvider.tags;

      await libraryProvider.autoSaveWithDetails(
        content, 
        title: title,
        tags: tags.isNotEmpty ? tags : null,
      );
    }
  }

  @override
  void dispose() {
    final editorProvider = Provider.of<EditorProvider>(context, listen: false);
    editorProvider.removeListener(_updateControllerFromProvider);
    _autoSaveTimer?.cancel();
    _controller.dispose();
    _titleController.dispose();
    _editScrollController.dispose();
    _previewScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768; // Mobile breakpoint

    return Scaffold(
      appBar: UbuntuHeaderBar(
        isMobile: isMobile,
        onPublish: () => _showPublishDialog(context),
        onSettings: () => _showSettings(context),
      ),
      drawer: isMobile ? const LibrarySidebar() : null,
      body: Row(
        children: [
          if (!isMobile) const LibrarySidebar(),
          Expanded(
            child: Column(
              children: [
                const EditorToolbar(),
                _buildTitleSection(),
                _buildTagsSection(),
                Expanded(
                  child: Consumer<EditorProvider>(
                    builder: (context, provider, child) {
                      if (provider.error != null) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: SelectableText(
                                provider.error!,
                                style: const TextStyle(color: Colors.white),
                              ),
                              duration: const Duration(
                                  seconds: 10), // Longer duration for copying
                              action: SnackBarAction(
                                label: 'Dismiss',
                                onPressed: provider.clearError,
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        });
                      }

                      return _buildEditor(provider);
                    },
                  ),
                ),
                const StatusBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditor(EditorProvider provider) {
    switch (provider.viewMode) {
      case ViewMode.edit:
        return _buildEditView();
      case ViewMode.preview:
        return _buildPreviewView(provider.content);
      case ViewMode.split:
        return Row(
          children: [
            Expanded(child: _buildEditView()),
            const VerticalDivider(width: 1),
            Expanded(child: _buildPreviewView(provider.content)),
          ],
        );
    }
  }

  Widget _buildEditView() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: TextField(
        controller: _controller,
        scrollController: _editScrollController,
        maxLines: null,
        expands: true,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Start typing your markdown here...',
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            fontSize: 16,
            fontFamily: 'JetBrains Mono',
          ),
        ),
        style: TextStyle(
          fontFamily: 'JetBrains Mono',
          fontSize: 16,
          height: 1.6,
          color: Theme.of(context).colorScheme.onSurface,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildPreviewView(String content) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          final isDarkMode = themeProvider.isDarkMode ||
              (themeProvider.isSystemMode &&
                  MediaQuery.of(context).platformBrightness == Brightness.dark);

          return Markdown(
            data: content,
            controller: _previewScrollController,
            selectable: true,
            extensionSet: md.ExtensionSet.gitHubFlavored,
            builders: {
              'pre': CodeElementBuilder(isDarkMode: isDarkMode),
              'code': CodeElementBuilder(isDarkMode: isDarkMode),
            },
            styleSheet:
                MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
              h1: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontFamily: 'Georgia',
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
              h2: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontFamily: 'Georgia',
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    letterSpacing: -0.3,
                  ),
              h3: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontFamily: 'Georgia',
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
              h4: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontFamily: 'Georgia',
                    fontWeight: FontWeight.w600,
                  ),
              h5: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontFamily: 'Georgia',
                    fontWeight: FontWeight.w600,
                  ),
              h6: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontFamily: 'Georgia',
                    fontWeight: FontWeight.w600,
                  ),
              p: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontFamily: 'Inter',
                    height: 1.7,
                    fontSize: 16,
                  ),
              blockquote: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontFamily: 'Georgia',
                    fontStyle: FontStyle.italic,
                    height: 1.6,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.8),
                  ),
              code: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 14,
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withOpacity(0.8),
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              // Remove default code block styling since we're using custom builder
              codeblockDecoration: const BoxDecoration(),
              codeblockPadding: EdgeInsets.zero,
              blockquoteDecoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 4,
                  ),
                ),
              ),
              blockquotePadding:
                  const EdgeInsets.only(left: 16, top: 8, bottom: 8),
              listBullet: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontFamily: 'Inter',
                    height: 1.6,
                  ),
              tableHead: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
              tableBody: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Inter',
                    height: 1.5,
                  ),
            ),
          );
        },
      ),
    );
  }

  void _showPublishDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const PublishDialog(),
    );
  }

  void _showSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Consumer2<EditorProvider, LibraryProvider>(
      builder: (context, editorProvider, libraryProvider, child) {
        // Determine which title to show and edit permissions
        final currentDocument = libraryProvider.currentDocument;
        final isViewingDocument = currentDocument != null;
        final canEdit = !isViewingDocument || !currentDocument.isPosted;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.title,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isViewingDocument && currentDocument.isPosted
                          ? 'Published Title'
                          : 'Post Title',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleController,
                  enabled: canEdit,
                  decoration: InputDecoration(
                    hintText: canEdit
                        ? 'Enter post title...'
                        : 'No title was set for this post',
                    border: const OutlineInputBorder(),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: canEdit
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTagsSection() {
    return Consumer2<EditorProvider, LibraryProvider>(
      builder: (context, editorProvider, libraryProvider, child) {
        // Determine which tags to show:
        // - If viewing a specific document, show its tags
        // - If creating/editing, show editor provider tags
        final currentDocument = libraryProvider.currentDocument;
        final isViewingDocument = currentDocument != null;
        final tagsToShow =
            isViewingDocument ? currentDocument.tags : editorProvider.tags;
        final canEdit = !isViewingDocument || !currentDocument.isPosted;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with toggle button
              InkWell(
                onTap: () {
                  setState(() {
                    _showTags = !_showTags;
                  });
                },
                child: Container(
                  height: 40,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.tag,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isViewingDocument && currentDocument.isPosted
                            ? 'Published Tags'
                            : 'Tags',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      if (tagsToShow.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${tagsToShow.length}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                      // Show published platforms for posted documents
                      if (isViewingDocument &&
                          currentDocument.isPosted &&
                          currentDocument.publishedPlatforms.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        ...currentDocument.publishedPlatforms
                            .map((platform) => Container(
                                  margin: const EdgeInsets.only(left: 4),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: platform == 'Nostr'
                                        ? Colors.purple.withOpacity(0.2)
                                        : Colors.blue.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    platform,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: platform == 'Nostr'
                                          ? Colors.purple[700]
                                          : Colors.blue[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )),
                      ],
                      const Spacer(),
                      Icon(
                        _showTags ? Icons.expand_less : Icons.expand_more,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),

              // Expanded tags content
              if (_showTags) ...[
                const Divider(height: 1),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 150),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: canEdit
                        ? TagInput(
                            tags: tagsToShow,
                            onTagAdd: editorProvider.addTag,
                            onTagRemove: editorProvider.removeTag,
                            hint: 'Add tags for this post...',
                          )
                        : _buildReadOnlyTags(tagsToShow),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildReadOnlyTags(List<String> tags) {
    if (tags.isEmpty) {
      return const Text(
        'No tags were used when this post was published.',
        style: TextStyle(
          fontStyle: FontStyle.italic,
          color: Colors.grey,
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: tags
          .map((tag) => Chip(
                label: Text(tag),
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
              ))
          .toList(),
    );
  }
}

class CodeElementBuilder extends MarkdownElementBuilder {
  final bool isDarkMode;

  CodeElementBuilder({required this.isDarkMode});

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    // Handle code blocks - they come as 'code' elements with class attributes for fenced blocks
    if (element.tag == 'code' && element.attributes.containsKey('class')) {
      final String? classAttr = element.attributes['class'];
      String? language;

      if (classAttr != null && classAttr.startsWith('language-')) {
        language = classAttr.replaceFirst('language-', '');
      }

      final String textContent = element.textContent;

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: CodeHighlighter(
          code: textContent.trim(),
          language: language,
          isDarkMode: isDarkMode,
        ),
      );
    }

    return null;
  }
}
