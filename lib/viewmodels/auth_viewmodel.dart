import 'dart:async';
import 'package:children_stories/core/services/adapty_service.dart';
import 'package:children_stories/data/models/profile_model.dart';
import 'package:children_stories/data/repositories/auth_repository.dart';
import 'package:children_stories/data/repositories/profile_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();
  final ProfileRepository _profileRepository = ProfileRepository();

  User? _currentUser;
  UserProfile? _profile;
  bool _isLoading = false;
  String? _error;
  bool _hasFinishedAuthSelection = false;
  bool _isInitialized = false;
  StreamSubscription<AuthState>? _authSubscription;
  bool _isDisposed = false;

  bool _localOnboardingCompleted = false;
  int? _localAge;
  String? _localGender;

  User? get currentUser => _currentUser;
  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  bool get hasCompletedOnboarding => _localOnboardingCompleted;
  bool get hasFinishedAuthSelection => _hasFinishedAuthSelection || (isLoggedIn && !isAnonymous);
  bool get isInitialized => _isInitialized;
  bool get isAnonymous => _currentUser?.isAnonymous ?? true;

  bool get localOnboardingCompleted => _localOnboardingCompleted;
  int? get localAge => _localAge;
  String? get localGender => _localGender;

  AuthViewModel() {
    _currentUser = Supabase.instance.client.auth.currentUser;
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    await _authSubscription?.cancel();
    _authSubscription = _repository.authStateStream.listen((event) async {
      final user = Supabase.instance.client.auth.currentUser;
      final isAnonymousChanged = user?.isAnonymous != _currentUser?.isAnonymous;
      final isIdChanged = user?.id != _currentUser?.id;
      
      if (isIdChanged || isAnonymousChanged) {
        _currentUser = user;
        if (user != null) {
          await _loadProfile(user.id);
          if (!user.isAnonymous) {
            _hasFinishedAuthSelection = true;
            await AdaptyService.identify(user.id);
          } else {
            await AdaptyService.logout();
          }
        } else {
          _profile = null;
          await AdaptyService.logout();
        }
        notifyListeners();
      }
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      _localOnboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
      _localAge = prefs.getInt('onboarding_age');
      _localGender = prefs.getString('onboarding_gender');

      if (_currentUser != null) {
        await _loadProfile(_currentUser!.id);
        if (_profile?.childAge != null) {
          _hasFinishedAuthSelection = true;
        }
        if (!_currentUser!.isAnonymous) {
          await AdaptyService.identify(_currentUser!.id);
        } else {
          await AdaptyService.logout();
        }
      } else {
        await AdaptyService.logout();
      }
    } catch (e) {
      debugPrint('[AuthVM] initialization error: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _loadProfile(String userId) async {
    try {
      _profile = await _profileRepository.getProfile(userId);
    } catch (e) {
      debugPrint('[AuthVM] loadProfile error: $e');
    }
  }

  Future<void> _syncLocalOnboardingToProfile(String userId) async {
    try {
      final currentProfile = await _profileRepository.getProfile(userId);
      final age = currentProfile?.childAge ?? _localAge;
      final gender = currentProfile?.childGender ?? _localGender;
      if (age != null || gender != null) {
        await _profileRepository.updateChildInfo(userId, age: age, gender: gender);
      }
      await _loadProfile(userId);
    } catch (e) {
      debugPrint('[AuthVM] _syncLocalOnboardingToProfile error: $e');
    }
  }

  Future<void> updateOnboardingData({required int age, String? gender}) async {
    final uid = _currentUser?.id;
    if (uid == null) return;
    
    _setLoading(true);
    try {
      await _profileRepository.updateChildInfo(uid, age: age, gender: gender);
      await _loadProfile(uid);
    } catch (e) {
      debugPrint('[AuthVM] updateOnboardingData error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> completeLocalOnboarding({required int age, String? gender}) async {
    _localAge = age;
    _localGender = gender;
    _localOnboardingCompleted = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);
      await prefs.setInt('onboarding_age', age);
      if (gender != null) {
        await prefs.setString('onboarding_gender', gender);
      } else {
        await prefs.remove('onboarding_gender');
      }
    } catch (e) {
      debugPrint('[AuthVM] completeLocalOnboarding error: $e');
    }
    notifyListeners();
  }

  Future<void> signInAnonymously() async {
    _setLoading(true);
    _clearError();
    try {
      await _repository.signInAnonymously();
    } catch (e) {
      _setError(_friendlyError(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> continueWithoutSignIn() async {
    _setLoading(true);
    _clearError();
    try {
      await _repository.signInAnonymously();
      final uid = _repository.currentUser?.id;
      if (uid != null) {
        if (_localAge != null) {
          await _profileRepository.updateChildInfo(uid, age: _localAge!, gender: _localGender);
        }
        await _loadProfile(uid);
      }
      _hasFinishedAuthSelection = true;
      notifyListeners();
    } catch (e) {
      _setError(_friendlyError(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithGoogle() async {
    _setLoading(true);
    _clearError();
    try {
      debugPrint('[AuthViewModel] signInWithGoogle called');
      await _repository.signInWithGoogle();
      final uid = _currentUser?.id;
      debugPrint('[AuthViewModel] Sign-In repository call finished. User ID: $uid');
      if (uid != null) {
        debugPrint('[AuthViewModel] Syncing onboarding data to profile for: $uid');
        await _syncLocalOnboardingToProfile(uid);
        debugPrint('[AuthViewModel] Sync onboarding finished.');
      }
    } catch (e, stackTrace) {
      debugPrint('[AuthViewModel] signInWithGoogle failed: $e');
      debugPrint('[AuthViewModel] Stacktrace: $stackTrace');
      _setError(_friendlyError(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithApple() async {
    _setLoading(true);
    _clearError();
    try {
      await _repository.signInWithApple();
      final uid = _currentUser?.id;
      if (uid != null) {
        await _syncLocalOnboardingToProfile(uid);
      }
    } catch (e) {
      _setError(_friendlyError(e));
    } finally {
      _setLoading(false);
    }
  }



  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _repository.signOut();
      _profile = null;
      _currentUser = null;
      _hasFinishedAuthSelection = false;
      _isInitialized = false;
      notifyListeners();
    } catch (e) {
      debugPrint('[AuthVM] signOut error: $e');
    } finally {
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  void clearError() => _clearError();

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String? v) {
    _error = v;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  String _friendlyError(dynamic e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('cancel')) return 'Sign-in was cancelled.';
    if (msg.contains('network')) return 'No connection. Please check your internet.';
    return 'Sign-in failed: $e';
  }
}
