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

  factory BookPage.fromJson(Map<String, dynamic> json) {
    return BookPage(
      id: json['id'] as String? ?? '${json['book_id']}_${json['page_number']}',
      bookId: json['book_id'] as String,
      pageNumber: json['page_number'] as int,
      imageUrl: json['image_url'] as String?,
      textContent: json['text_content'] as String? ?? '',
      audioSeekSeconds: (json['audio_seek_seconds'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}
