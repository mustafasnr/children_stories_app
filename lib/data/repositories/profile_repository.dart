import 'package:children_stories/core/constants/supabase_constants.dart';
import 'package:children_stories/data/models/profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<UserProfile?> getProfile(String userId) async {
    final data = await _client
        .from(SupabaseConstants.profilesTable)
        .select()
        .eq('id', userId)
        .maybeSingle();
    return data == null ? null : UserProfile.fromJson(data);
  }

  Future<void> updateProfile(
    String userId, {
    String? displayName,
    String? avatarUrl,
  }) async {
    await _client
        .from(SupabaseConstants.profilesTable)
        .update({
          'display_name': displayName,
          'avatar_url': avatarUrl,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userId);
  }

  Future<void> updateChildInfo(
    String userId, {
    int? age,
    String? gender,
  }) async {
    await _client
        .from(SupabaseConstants.profilesTable)
        .update({
          'child_age': age,
          'child_gender': gender,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userId);
  }

  Future<void> updatePremiumStatus(
    String userId, {
    required bool isPremium,
  }) async {
    await _client
        .from(SupabaseConstants.profilesTable)
        .update({
          'is_premium': isPremium,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userId);
  }
}
