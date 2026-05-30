class BookPage {
  final String id;
  final String bookId;
  final int pageNumber;
  final String? imageUrl;
  final String textContent;
  final double audioSeekSeconds;
  final DateTime createdAt;

  const BookPage({
    required this.id,
    required this.bookId,
    required this.pageNumber,
    this.imageUrl,
    required this.textContent,
    this.audioSeekSeconds = 0.0,
    required this.createdAt,
  });

  /// Parse from Supabase join query:
  /// pages + page_translations!inner(text_content, audio_seek_seconds)
  factory BookPage.fromJson(Map<String, dynamic> json) {
    final translations = json['page_translations'];
    String textContent = '';
    double audioSeekSeconds = 0.0;

    if (translations is List && translations.isNotEmpty) {
      final transMap = translations[0] as Map<String, dynamic>;
      textContent = transMap['text_content'] as String? ?? '';
      audioSeekSeconds = (transMap['audio_seek_seconds'] as num?)?.toDouble() ?? 0.0;
    } else if (translations is Map<String, dynamic>) {
      textContent = translations['text_content'] as String? ?? '';
      audioSeekSeconds = (translations['audio_seek_seconds'] as num?)?.toDouble() ?? 0.0;
    } else {
      textContent = json['text_content'] as String? ?? '';
      audioSeekSeconds = (json['audio_seek_seconds'] as num?)?.toDouble() ?? 0.0;
    }

    return BookPage(
      id: json['id'] as String,
      bookId: json['book_id'] as String,
      pageNumber: json['page_number'] as int,
      imageUrl: json['image_url'] as String?,
      textContent: textContent,
      audioSeekSeconds: audioSeekSeconds,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
