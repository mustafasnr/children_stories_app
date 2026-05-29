class UserProfile {
  final String id;
  final String? displayName;
  final String? avatarUrl;
  final bool isPremium;
  final String? adaptyCustomerUserId;
  final int? childAge;
  final String? childGender;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    this.displayName,
    this.avatarUrl,
    this.isPremium = false,
    this.adaptyCustomerUserId,
    this.childAge,
    this.childGender,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        displayName: json['display_name'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        isPremium: json['is_premium'] as bool? ?? false,
        adaptyCustomerUserId: json['adapty_customer_user_id'] as String?,
        childAge: json['child_age'] as int?,
        childGender: json['child_gender'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  String get initials {
    if (displayName != null && displayName!.isNotEmpty) {
      final parts = displayName!.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return displayName![0].toUpperCase();
    }
    return '?';
  }

  UserProfile copyWith({
    bool? isPremium,
    String? displayName,
    String? avatarUrl,
    int? childAge,
    String? childGender,
  }) {
    return UserProfile(
      id: id,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isPremium: isPremium ?? this.isPremium,
      adaptyCustomerUserId: adaptyCustomerUserId,
      childAge: childAge ?? this.childAge,
      childGender: childGender ?? this.childGender,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
