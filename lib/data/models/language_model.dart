class Language {
  final int id;
  final String code;
  final String name;
  final String flagEmoji;
  final int sortOrder;
  final int storyCount;

  const Language({
    required this.id,
    required this.code,
    required this.name,
    required this.flagEmoji,
    this.sortOrder = 0,
    this.storyCount = 0,
  });

  String get countryCode {
    switch (code.toLowerCase()) {
      case 'en':
        return 'gb';
      case 'ja':
        return 'jp';
      case 'zh':
        return 'cn';
      case 'ar':
        return 'sa';
      case 'ko':
        return 'kr';
      case 'el':
        return 'gr';
      case 'he':
        return 'il';
      case 'hi':
        return 'in';
      default:
        return code;
    }
  }

  factory Language.fromJson(Map<String, dynamic> json) => Language(
        id: json['id'] as int,
        code: json['code'] as String,
        name: json['name'] as String,
        flagEmoji: json['flag_emoji'] as String,
        sortOrder: json['sort_order'] as int? ?? 0,
        storyCount: json['story_count'] as int? ?? 0,
      );

  @override
  bool operator ==(Object other) => other is Language && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => '$flagEmoji $name';
}
