class Book {
  final String id;
  final String title;
  final String? description;
  final String? coverUrl;
  final int? categoryId;
  final bool isPremium;
  final bool isFeatured;
  final int ageMin;
  final int ageMax;
  final int readTimeMinutes;
  final int pageCount;
  final DateTime createdAt;

  const Book({
    required this.id,
    required this.title,
    this.description,
    this.coverUrl,
    this.categoryId,
    this.isPremium = false,
    this.isFeatured = false,
    this.ageMin = 3,
    this.ageMax = 10,
    this.readTimeMinutes = 5,
    this.pageCount = 0,
    required this.createdAt,
  });

  /// Parse from Supabase join query:
  /// books + book_translations!inner(title, description)
  factory Book.fromJson(Map<String, dynamic> json) {
    // Translation data comes nested from the join
    final translations = json['book_translations'];
    String title = '';
    String? description;

    if (translations is List && translations.isNotEmpty) {
      final t = translations[0] as Map<String, dynamic>;
      title = t['title'] as String? ?? '';
      description = t['description'] as String?;
    } else if (translations is Map<String, dynamic>) {
      title = translations['title'] as String? ?? '';
      description = translations['description'] as String?;
    } else {
      // Fallback: title might be directly on the row (e.g. from a view)
      title = json['title'] as String? ?? '';
      description = json['description'] as String?;
    }

    return Book(
      id: json['id'] as String,
      title: title,
      description: description,
      coverUrl: json['cover_url'] as String?,
      categoryId: json['category_id'] as int?,
      isPremium: json['is_premium'] as bool? ?? false,
      isFeatured: json['is_featured'] as bool? ?? false,
      ageMin: json['age_min'] as int? ?? 3,
      ageMax: json['age_max'] as int? ?? 10,
      readTimeMinutes: json['read_time_minutes'] as int? ?? 5,
      pageCount: json['page_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  String get ageRange => '$ageMin–$ageMax yrs';
  String get readTime => '$readTimeMinutes min read';

  @override
  bool operator ==(Object other) => other is Book && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
