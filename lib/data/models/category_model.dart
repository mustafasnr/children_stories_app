class Category {
  final int id;
  final String slug;
  final String name;
  final String icon;
  final int sortOrder;

  const Category({
    required this.id,
    required this.slug,
    required this.name,
    this.icon = '📖',
    this.sortOrder = 0,
  });

  /// Parse from Supabase join query:
  /// categories + category_translations!inner(name)
  factory Category.fromJson(Map<String, dynamic> json) {
    final translations = json['category_translations'];
    String name = '';

    if (translations is List && translations.isNotEmpty) {
      name = (translations[0] as Map<String, dynamic>)['name'] as String? ?? '';
    } else if (translations is Map<String, dynamic>) {
      name = translations['name'] as String? ?? '';
    } else {
      name = json['name'] as String? ?? json['slug'] as String? ?? '';
    }

    return Category(
      id: json['id'] as int,
      slug: json['slug'] as String? ?? '',
      name: name,
      icon: json['icon'] as String? ?? '📖',
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  @override
  bool operator ==(Object other) => other is Category && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
