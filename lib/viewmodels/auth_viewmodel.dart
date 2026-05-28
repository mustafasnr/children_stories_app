import 'package:children_stories/data/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;

  AuthViewModel() {
    _currentUser = Supabase.instance.client.auth.currentUser;
    _repository.authStateStream.listen((event) {
      _currentUser = event.session?.user;
      notifyListeners();
    });
  }

  Future<void> signInWithGoogle() async {
    _setLoading(true);
    _clearError();
    try {
      await _repository.signInWithGoogle();
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
      await _repository.signInWithApple();
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
