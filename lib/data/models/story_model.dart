class Story {
  final String id;
  final String title;
  final String? description;
  final String? coverUrl;
  final int? languageId;
  final int? categoryId;
  final bool isPremium;
  final bool isFeatured;
  final int ageMin;
  final int ageMax;
  final int readTimeMinutes;
  final int pageCount;
  final DateTime createdAt;

  const Story({
    required this.id,
    required this.title,
    this.description,
    this.coverUrl,
    this.languageId,
    this.categoryId,
    this.isPremium = false,
    this.isFeatured = false,
    this.ageMin = 3,
    this.ageMax = 10,
    this.readTimeMinutes = 5,
    this.pageCount = 0,
    required this.createdAt,
  });

  factory Story.fromJson(Map<String, dynamic> json) => Story(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        coverUrl: json['cover_url'] as String?,
        languageId: json['language_id'] as int?,
        categoryId: json['category_id'] as int?,
        isPremium: json['is_premium'] as bool? ?? false,
        isFeatured: json['is_featured'] as bool? ?? false,
        ageMin: json['age_min'] as int? ?? 3,
        ageMax: json['age_max'] as int? ?? 10,
        readTimeMinutes: json['read_time_minutes'] as int? ?? 5,
        pageCount: json['page_count'] as int? ?? 0,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  String get ageRange => '$ageMin–$ageMax yrs';
  String get readTime => '$readTimeMinutes min read';

  @override
  bool operator ==(Object other) => other is Story && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
