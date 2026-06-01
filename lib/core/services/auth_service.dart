import 'dart:convert';
import 'dart:math';
import 'package:children_stories/core/constants/app_constants.dart';
import 'package:children_stories/core/services/adapty_service.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final SupabaseClient _client = Supabase.instance.client;

  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static bool _googleSignInInitialized = false;

  static Future<void> _ensureGoogleSignInInitialized() async {
    if (!_googleSignInInitialized) {
      await _googleSignIn.initialize(
        serverClientId: AppConstants.googleWebClientId,
      );
      _googleSignInInitialized = true;
    }
  }

  static Session? get currentSession => _client.auth.currentSession;
  static User? get currentUser => _client.auth.currentUser;
  static bool get isLoggedIn => currentSession != null;
  static Stream<AuthState> get authStateStream =>
      _client.auth.onAuthStateChange;

  static Future<void> signInAnonymously() async {
    await _client.auth.signInAnonymously();
    await AdaptyService.logout();
  }

  static Future<void> signInWithGoogle() async {
    try {
      debugPrint('[AuthService] Starting Google Sign-In...');
      await _ensureGoogleSignInInitialized();
      debugPrint('[AuthService] Google Sign-In initialized successfully.');
      
      debugPrint('[AuthService] Authenticating via GoogleSignIn...');
      final googleUser = await _googleSignIn.authenticate();
      debugPrint('[AuthService] Authenticated. Google User: $googleUser');

      debugPrint('[AuthService] Getting authentication tokens...');
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;
      debugPrint('[AuthService] ID Token: ${idToken != null ? "FOUND (len: ${idToken.length})" : "NULL"}');
      
      if (idToken == null) throw Exception('No ID token received from Google');

      debugPrint('[AuthService] Signing in to Supabase with ID Token...');
      await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
      debugPrint('[AuthService] Supabase sign-in success. Current User ID: ${_client.auth.currentUser?.id}');

      // Identify user in Adapty
      final uid = _client.auth.currentUser?.id;
      if (uid != null) {
        debugPrint('[AuthService] Identifying user $uid in Adapty...');
        await AdaptyService.identify(uid);
        debugPrint('[AuthService] Adapty identify success.');
      }
    } catch (e, stackTrace) {
      debugPrint('[AuthService] Error in signInWithGoogle: $e');
      debugPrint('[AuthService] Stacktrace: $stackTrace');
      rethrow;
    }
  }


  static Future<void> signInWithApple() async {
    final rawNonce = _generateNonce();
    final nonce = _sha256ofString(rawNonce);

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    final idToken = credential.identityToken;
    if (idToken == null) throw Exception('No ID token received from Apple');

    await _client.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: idToken,
      nonce: rawNonce,
    );

    final uid = _client.auth.currentUser?.id;
    if (uid != null) await AdaptyService.identify(uid);
  }



  static Future<void> signOut() async {
    try {
      await _ensureGoogleSignInInitialized();
      await _googleSignIn.signOut();
    } catch (_) {}
    await AdaptyService.logout();
    await _client.auth.signOut();
  }

  static String _generateNonce([int length = 32]) {
    const chars =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }

  static String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }
}
