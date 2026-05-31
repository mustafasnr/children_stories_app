import 'package:children_stories/data/models/profile_model.dart';
import 'package:children_stories/data/repositories/auth_repository.dart';
import 'package:children_stories/data/repositories/profile_repository.dart';
import 'package:children_stories/data/repositories/bookmark_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();
  final ProfileRepository _profileRepository = ProfileRepository();
  final BookmarkRepository _bookmarkRepository = BookmarkRepository();

  User? _currentUser;
  UserProfile? _profile;
  bool _isLoading = false;
  String? _error;
  bool _hasFinishedAuthSelection = false;
  bool _isInitialized = false;

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
    _repository.authStateStream.listen((event) async {
      final user = Supabase.instance.client.auth.currentUser;
      final isAnonymousChanged = user?.isAnonymous != _currentUser?.isAnonymous;
      final isIdChanged = user?.id != _currentUser?.id;
      
      if (isIdChanged || isAnonymousChanged) {
        _currentUser = user;
        if (user != null) {
          await _loadProfile(user.id);
          if (!user.isAnonymous) {
            _hasFinishedAuthSelection = true;
          }
        } else {
          _profile = null;
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
      // 1. Store anonymous info first
      final anonymousAge = _profile?.childAge;
      final anonymousGender = _profile?.childGender;
      final anonymousUid = _currentUser?.id;

      // 2. Perform native sign in
      await _repository.signInWithGoogle();

      // 3. Merge profiles
      await _mergeAnonymousDataToNewUser(anonymousUid, anonymousAge, anonymousGender);
    } catch (e) {
      _setError(_friendlyError(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithApple() async {
    _setLoading(true);
    _clearError();
    try {
      // 1. Store anonymous info first
      final anonymousAge = _profile?.childAge;
      final anonymousGender = _profile?.childGender;
      final anonymousUid = _currentUser?.id;

      // 2. Perform native sign in
      await _repository.signInWithApple();

      // 3. Merge profiles
      await _mergeAnonymousDataToNewUser(anonymousUid, anonymousAge, anonymousGender);
    } catch (e) {
      _setError(_friendlyError(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> linkGoogle() async {
    _setLoading(true);
    _clearError();
    try {
      await _repository.linkGoogle();
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        _currentUser = user;
        await _loadProfile(user.id);
        if (!user.isAnonymous) {
          _hasFinishedAuthSelection = true;
        }
      }
    } on AuthException catch (e) {
      if (e.code == 'identity_already_exists') {
        debugPrint('[AuthVM] Google identity already exists, falling back to sign-in');
        await signInWithGoogle();
      } else {
        _setError(_friendlyError(e));
      }
    } catch (e) {
      _setError(_friendlyError(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> linkApple() async {
    _setLoading(true);
    _clearError();
    try {
      await _repository.linkApple();
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        _currentUser = user;
        await _loadProfile(user.id);
        if (!user.isAnonymous) {
          _hasFinishedAuthSelection = true;
        }
      }
    } on AuthException catch (e) {
      if (e.code == 'identity_already_exists') {
        debugPrint('[AuthVM] Apple identity already exists, falling back to sign-in');
        await signInWithApple();
      } else {
        _setError(_friendlyError(e));
      }
    } catch (e) {
      _setError(_friendlyError(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _mergeAnonymousDataToNewUser(String? oldUid, int? anonAge, String? anonGender) async {
    final newUid = _currentUser?.id;
    if (newUid == null) return;

    try {
      final newProfile = await _profileRepository.getProfile(newUid);
      
      final mergedAge = newProfile?.childAge ?? _localAge ?? anonAge;
      final mergedGender = newProfile?.childGender ?? _localGender ?? anonGender;

      if (mergedAge != null || mergedGender != null) {
        await _profileRepository.updateChildInfo(newUid, age: mergedAge, gender: mergedGender);
      }
      
      // Migrate bookmarks if they signed in anonymously first
      if (oldUid != null && oldUid != newUid) {
        await _bookmarkRepository.migrateBookmarks(oldUid, newUid);
      }

      await _loadProfile(newUid);
      _hasFinishedAuthSelection = true;
      notifyListeners();
    } catch (e) {
      debugPrint('[AuthVM] merge error: $e');
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
      
      await _initializeAuth();
    } catch (e) {
      debugPrint('[AuthVM] signOut error: $e');
    } finally {
      _setLoading(false);
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
    return 'Sign-in failed. Please try again.';
  }
}
