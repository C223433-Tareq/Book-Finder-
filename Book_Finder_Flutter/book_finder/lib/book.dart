class Book {
  const Book({
    required this.title,
    required this.authors,
    this.firstPublished,
    this.coverId,
  });

  final String title;
  final String authors;
  final int? firstPublished;
  final int? coverId;

  factory Book.fromJson(Map<String, dynamic> json) {
    final authors = (json['author_name'] as List<dynamic>?)
        ?.whereType<String>()
        .where((name) => name.trim().isNotEmpty)
        .join(', ');

    return Book(
      title: json['title'] as String? ?? 'Untitled',
      authors: authors == null || authors.isEmpty ? 'Unknown author' : authors,
      firstPublished: json['first_publish_year'] as int?,
      coverId: json['cover_i'] as int?,
    );
  }
}
