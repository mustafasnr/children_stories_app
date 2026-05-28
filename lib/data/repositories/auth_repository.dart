import 'package:children_stories/core/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  Session? get currentSession => AuthService.currentSession;
  User? get currentUser => AuthService.currentUser;
  bool get isLoggedIn => AuthService.isLoggedIn;
  Stream<AuthState> get authStateStream => AuthService.authStateStream;

  Future<void> signInWithGoogle() => AuthService.signInWithGoogle();
  Future<void> signInWithApple() => AuthService.signInWithApple();
  Future<void> signOut() => AuthService.signOut();
}
