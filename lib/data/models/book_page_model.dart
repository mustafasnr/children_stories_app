class BookPage {
  final String id;
  final String bookId;
  final int pageNumber;
  final String? imageUrl;
  final String textContent;
  final DateTime createdAt;

  const BookPage({
    required this.id,
    required this.bookId,
    required this.pageNumber,
    this.imageUrl,
    required this.textContent,
    required this.createdAt,
  });

  /// Parse from Supabase join query:
  /// pages + page_translations!inner(text_content)
  factory BookPage.fromJson(Map<String, dynamic> json) {
    final translations = json['page_translations'];
    String textContent = '';

    if (translations is List && translations.isNotEmpty) {
      textContent =
          (translations[0] as Map<String, dynamic>)['text_content'] as String? ??
              '';
    } else if (translations is Map<String, dynamic>) {
      textContent = translations['text_content'] as String? ?? '';
    } else {
      textContent = json['text_content'] as String? ?? '';
    }

    return BookPage(
      id: json['id'] as String,
      bookId: json['book_id'] as String,
      pageNumber: json['page_number'] as int,
      imageUrl: json['image_url'] as String?,
      textContent: textContent,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
