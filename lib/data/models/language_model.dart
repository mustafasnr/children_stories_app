class Language {
  final int id;
  final String code;
  final String name;
  final String flagEmoji;
  final int sortOrder;

  const Language({
    required this.id,
    required this.code,
    required this.name,
    required this.flagEmoji,
    this.sortOrder = 0,
  });

  factory Language.fromJson(Map<String, dynamic> json) => Language(
        id: json['id'] as int,
        code: json['code'] as String,
        name: json['name'] as String,
        flagEmoji: json['flag_emoji'] as String,
        sortOrder: json['sort_order'] as int? ?? 0,
      );

  @override
  bool operator ==(Object other) => other is Language && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => '$flagEmoji $name';
}
