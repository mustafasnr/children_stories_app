import 'package:children_stories/data/models/subscription_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubscriptionRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<UserSubscription?> getSubscription(String userId) async {
    try {
      final data = await _client
          .from('subscriptions')
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (data == null) return null;
      return UserSubscription.fromJson(data);
    } catch (e) {
      return null;
    }
  }
}
