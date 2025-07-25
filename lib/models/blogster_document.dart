class BlogsterDocument {
  final String id;
  final String filename;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final bool isPosted;
  final String filePath;
  final List<String> tags;
  final List<String> publishedPlatforms;

  const BlogsterDocument({
    required this.id,
    required this.filename,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.modifiedAt,
    required this.isPosted,
    required this.filePath,
    this.tags = const [],
    this.publishedPlatforms = const [],
  });

  BlogsterDocument copyWith({
    String? id,
    String? filename,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? modifiedAt,
    bool? isPosted,
    String? filePath,
    List<String>? tags,
    List<String>? publishedPlatforms,
  }) {
    return BlogsterDocument(
      id: id ?? this.id,
      filename: filename ?? this.filename,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      isPosted: isPosted ?? this.isPosted,
      filePath: filePath ?? this.filePath,
      tags: tags ?? this.tags,
      publishedPlatforms: publishedPlatforms ?? this.publishedPlatforms,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'filename': filename,
        'title': title,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'modifiedAt': modifiedAt.toIso8601String(),
        'isPosted': isPosted,
        'filePath': filePath,
        'tags': tags,
        'publishedPlatforms': publishedPlatforms,
      };

  factory BlogsterDocument.fromJson(Map<String, dynamic> json) =>
      BlogsterDocument(
        id: json['id'],
        filename: json['filename'],
        title: json['title'],
        content: json['content'],
        createdAt: DateTime.parse(json['createdAt']),
        modifiedAt: DateTime.parse(json['modifiedAt']),
        isPosted: json['isPosted'],
        filePath: json['filePath'],
        tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
        publishedPlatforms: json['publishedPlatforms'] != null
            ? List<String>.from(json['publishedPlatforms'])
            : [],
      );

  /// Extract title from content (first line or first few words)
  static String extractTitle(String content) {
    if (content.isEmpty) {
      return _generateDateTimeTitle();
    }

    // Remove markdown headers
    String firstLine = content.split('\n').first.trim();
    firstLine = firstLine.replaceAll(RegExp(r'^#+\s*'), '');

    if (firstLine.isEmpty) {
      return _generateDateTimeTitle();
    }

    // Take first few words, max 50 chars
    List<String> words = firstLine.split(' ');
    String title = '';
    for (String word in words) {
      if ((title + word).length > 50) break;
      title += (title.isEmpty ? '' : ' ') + word;
    }

    return title.isEmpty ? _generateDateTimeTitle() : title;
  }

  /// Generate a date/time based title
  static String _generateDateTimeTitle() {
    final now = DateTime.now();
    return 'Document ${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  /// Generate filename from title
  static String generateFilename(String title) {
    // Handle date/time based titles
    if (title.startsWith('Document ')) {
      final now = DateTime.now();
      return 'document_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}.md';
    }

    // Remove special characters and replace spaces with underscores
    String filename = title
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');

    if (filename.isEmpty) {
      final now = DateTime.now();
      filename =
          'untitled_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
    }

    return '$filename.md';
  }
}
