import 'package:children_stories/data/models/profile_model.dart';
import 'package:children_stories/data/repositories/profile_repository.dart';
import 'package:flutter/foundation.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _repository = ProfileRepository();

  UserProfile? _profile;
  bool _isLoading = false;
  String? _error;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProfile(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _profile = await _repository.getProfile(userId);
    } catch (e) {
      _error = 'Failed to load profile.';
      debugPrint('[ProfileVM] error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updatePremiumStatus(String userId, {required bool isPremium}) async {
    try {
      await _repository.updatePremiumStatus(userId, isPremium: isPremium);
      _profile = _profile?.copyWith(isPremium: isPremium);
      notifyListeners();
    } catch (e) {
      debugPrint('[ProfileVM] updatePremium error: $e');
    }
  }

  void reset() {
    _profile = null;
    _isLoading = false;
    _error = null;
  }
}
