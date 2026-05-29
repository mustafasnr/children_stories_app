import 'package:children_stories/data/models/profile_model.dart';
import 'package:children_stories/data/repositories/auth_repository.dart';
import 'package:children_stories/data/repositories/profile_repository.dart';
import 'package:flutter/foundation.dart';
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

  User? get currentUser => _currentUser;
  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  bool get hasCompletedOnboarding => _profile?.childAge != null;
  bool get hasFinishedAuthSelection => _hasFinishedAuthSelection;
  bool get isInitialized => _isInitialized;
  bool get isAnonymous => _currentUser?.isAnonymous ?? true;

  AuthViewModel() {
    _currentUser = Supabase.instance.client.auth.currentUser;
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    _repository.authStateStream.listen((event) async {
      final user = event.session?.user;
      
      if (user?.id != _currentUser?.id) {
        _currentUser = user;
        if (user != null) {
          await _loadProfile(user.id);
        } else {
          _profile = null;
        }
        notifyListeners();
      }
    });

    try {
      if (_currentUser == null) {
        await _repository.signInAnonymously();
      } else {
        await _loadProfile(_currentUser!.id);
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
      if (_profile?.childAge != null) {
        _hasFinishedAuthSelection = true;
      }
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

  void continueWithoutSignIn() {
    _hasFinishedAuthSelection = true;
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    _setLoading(true);
    _clearError();
    try {
      // 1. Store anonymous info first
      final anonymousAge = _profile?.childAge;
      final anonymousGender = _profile?.childGender;

      // 2. Perform native sign in
      await _repository.signInWithGoogle();

      // 3. Merge profiles
      await _mergeAnonymousDataToNewUser(anonymousAge, anonymousGender);
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

      // 2. Perform native sign in
      await _repository.signInWithApple();

      // 3. Merge profiles
      await _mergeAnonymousDataToNewUser(anonymousAge, anonymousGender);
    } catch (e) {
      _setError(_friendlyError(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _mergeAnonymousDataToNewUser(int? anonAge, String? anonGender) async {
    final newUid = _currentUser?.id;
    if (newUid == null) return;

    try {
      final newProfile = await _profileRepository.getProfile(newUid);
      
      final mergedAge = newProfile?.childAge ?? anonAge;
      final mergedGender = newProfile?.childGender ?? anonGender;

      if (mergedAge != null || mergedGender != null) {
        await _profileRepository.updateChildInfo(newUid, age: mergedAge, gender: mergedGender);
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
