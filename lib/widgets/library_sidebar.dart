import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/library_provider.dart';
import '../providers/editor_provider.dart';
import '../models/blogster_document.dart';

class LibrarySidebar extends StatefulWidget {
  const LibrarySidebar({super.key});

  @override
  State<LibrarySidebar> createState() => _LibrarySidebarState();
}

class _LibrarySidebarState extends State<LibrarySidebar> {
  bool _isExpanded = true;
  bool _isDraftsExpanded = true;
  bool _isPostedExpanded = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _closeMobileDrawer() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    if (isMobile && Scaffold.maybeOf(context)?.hasDrawer == true) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isInDrawer = Scaffold.maybeOf(context)?.hasDrawer == true;
    
    return Consumer<LibraryProvider>(
      builder: (context, libraryProvider, child) {
        if (libraryProvider.libraryPath == null) {
          return _buildInitializationView(libraryProvider);
        }

        return Container(
          width: isMobile || isInDrawer ? double.infinity : (_isExpanded ? 300 : 60),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: isInDrawer ? null : Border(
              right: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              _buildHeader(libraryProvider),
              if (_isExpanded || isMobile || isInDrawer) ...[
                _buildSearchBar(),
                _buildActionButtons(libraryProvider),
                Expanded(child: _buildDocumentsList(libraryProvider)),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildInitializationView(LibraryProvider libraryProvider) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Initialize Library',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a folder for your Blogster library or use the default location.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          if (libraryProvider.isLoading)
            const CircularProgressIndicator()
          else ...[
            ElevatedButton.icon(
              onPressed: () => _initializeDefaultLibrary(libraryProvider),
              icon: const Icon(Icons.home),
              label: const Text('Use Default Location'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _chooseCustomLocation(libraryProvider),
              icon: const Icon(Icons.folder_open),
              label: const Text('Choose Custom Location'),
            ),
          ],
          if (libraryProvider.error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                libraryProvider.error!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(LibraryProvider libraryProvider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isInDrawer = Scaffold.maybeOf(context)?.hasDrawer == true;
    
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          if (!isMobile && !isInDrawer) ...[
            IconButton(
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              icon: Icon(_isExpanded ? Icons.menu_open : Icons.menu),
              tooltip: _isExpanded ? 'Collapse sidebar' : 'Expand sidebar',
            ),
          ],
          if (_isExpanded || isMobile || isInDrawer) ...[
            Expanded(
              child: Text(
                'Library',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) => _handleMenuAction(value, libraryProvider),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'refresh',
                  child: Row(
                    children: [
                      Icon(Icons.refresh),
                      SizedBox(width: 8),
                      Text('Refresh'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'change_location',
                  child: Row(
                    children: [
                      Icon(Icons.folder_open),
                      SizedBox(width: 8),
                      Text('Change Location'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'show_path',
                  child: Row(
                    children: [
                      Icon(Icons.info_outline),
                      SizedBox(width: 8),
                      Text('Show Path'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search documents...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  icon: const Icon(Icons.clear),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildActionButtons(LibraryProvider libraryProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async => await _createNewDocument(),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('New'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsList(LibraryProvider libraryProvider) {
    final allDocuments = libraryProvider.documents;
    final filteredDocuments = _searchQuery.isEmpty
        ? allDocuments
        : allDocuments.where((doc) => 
            doc.title.toLowerCase().contains(_searchQuery) ||
            doc.filename.toLowerCase().contains(_searchQuery)
          ).toList();

    if (libraryProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filteredDocuments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isEmpty ? Icons.article_outlined : Icons.search_off,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty 
                  ? 'No documents yet\nCreate your first document!'
                  : 'No documents match your search',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    // Group documents by posted status
    final unpostedDocs = filteredDocuments.where((doc) => !doc.isPosted).toList();
    final postedDocs = filteredDocuments.where((doc) => doc.isPosted).toList();

    // Sort drafts by last modified date (most recent first)
    unpostedDocs.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: [
        if (unpostedDocs.isNotEmpty) ...[
          _buildCollapsibleSectionHeader('Drafts', unpostedDocs.length, _isDraftsExpanded, (expanded) {
            setState(() {
              _isDraftsExpanded = expanded;
            });
          }),
          if (_isDraftsExpanded) ...[
            ...unpostedDocs.map((doc) => _buildDocumentTile(doc, libraryProvider)),
            const SizedBox(height: 8),
          ],
        ],
        if (postedDocs.isNotEmpty) ...[
          _buildCollapsibleSectionHeader('Posted', postedDocs.length, _isPostedExpanded, (expanded) {
            setState(() {
              _isPostedExpanded = expanded;
            });
          }),
          if (_isPostedExpanded) ...[
            ...postedDocs.map((doc) => _buildDocumentTile(doc, libraryProvider)),
          ],
        ],
      ],
    );
  }

  Widget _buildCollapsibleSectionHeader(String title, int count, bool isExpanded, Function(bool) onToggle) {
    return InkWell(
      onTap: () => onToggle(!isExpanded),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              isExpanded ? Icons.expand_more : Icons.chevron_right,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count.toString(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentTile(BlogsterDocument document, LibraryProvider libraryProvider) {
    final isSelected = libraryProvider.currentDocument?.id == document.id;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2),
      elevation: isSelected ? 4 : 1,
      color: isSelected 
          ? Theme.of(context).colorScheme.primaryContainer 
          : null,
      child: ListTile(
        dense: true,
        leading: Icon(
          document.isPosted ? Icons.check_circle : Icons.edit_outlined,
          color: document.isPosted 
              ? Colors.green 
              : Theme.of(context).colorScheme.primary,
          size: 20,
        ),
        title: Text(
          document.title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected 
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : null,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          document.filename,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isSelected 
                ? Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7)
                : Theme.of(context).colorScheme.outline,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            size: 16,
            color: isSelected 
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : null,
          ),
          onSelected: (value) => _handleDocumentAction(value, document, libraryProvider),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'rename',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16),
                  SizedBox(width: 8),
                  Text('Rename'),
                ],
              ),
            ),
            if (!document.isPosted)
              const PopupMenuItem(
                value: 'mark_posted',
                child: Row(
                  children: [
                    Icon(Icons.publish, size: 16),
                    SizedBox(width: 8),
                    Text('Mark as Posted'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _loadDocument(document, libraryProvider),
      ),
    );
  }

  // Event handlers
  Future<void> _initializeDefaultLibrary(LibraryProvider libraryProvider) async {
    await libraryProvider.initializeLibrary();
  }

  Future<void> _chooseCustomLocation(LibraryProvider libraryProvider) async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      await libraryProvider.initializeLibrary(result);
    }
  }

  void _handleMenuAction(String action, LibraryProvider libraryProvider) {
    switch (action) {
      case 'refresh':
        libraryProvider.refresh();
        break;
      case 'change_location':
        _chooseCustomLocation(libraryProvider);
        break;
      case 'show_path':
        _showPathDialog();
        break;
    }
  }

  void _handleDocumentAction(String action, BlogsterDocument document, LibraryProvider libraryProvider) {
    switch (action) {
      case 'rename':
        _showRenameDialog(document, libraryProvider);
        break;
      case 'mark_posted':
        libraryProvider.markDocumentAsPosted(document.id);
        break;
      case 'delete':
        _showDeleteConfirmation(document, libraryProvider);
        break;
    }
  }

  Future<void> _createNewDocument() async {
    final libraryProvider = context.read<LibraryProvider>();
    final editorProvider = context.read<EditorProvider>();
    
    // Create a new document file immediately
    final newDocument = await libraryProvider.createNewDocumentFile();
    
    if (newDocument != null) {
      // Load the new document content into the editor
      editorProvider.updateContent(newDocument.content);
      
      // Close drawer on mobile after creating new document
      _closeMobileDrawer();
    }
  }

  Future<void> _loadDocument(BlogsterDocument document, LibraryProvider libraryProvider) async {
    await libraryProvider.loadDocument(document.id);
    
    // Update editor content
    if (mounted) {
      context.read<EditorProvider>().updateContent(document.content);
      
      // Close drawer on mobile after loading document
      _closeMobileDrawer();
    }
  }

  void _showPathDialog() {
    final libraryProvider = context.read<LibraryProvider>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Library Location'),
        content: SelectableText(libraryProvider.libraryPath ?? 'Not set'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(BlogsterDocument document, LibraryProvider libraryProvider) {
    final controller = TextEditingController(text: document.filename.replaceAll('.md', ''));
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Document'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Filename (without .md)',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                libraryProvider.renameDocument(document.id, newName);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BlogsterDocument document, LibraryProvider libraryProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text('Are you sure you want to delete "${document.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              libraryProvider.deleteDocument(document.id);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
