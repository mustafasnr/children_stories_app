import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  AppConstants._();

  // ─── Adapty ────────────────────────────────────────────────────────────────
  // Replace with your Adapty public API key from https://app.adapty.io/
  static String get adaptyPublicKey => dotenv.env['ADAPTY_PUBLIC_KEY'] ?? '';

  // Access level ID as configured in Adapty dashboard → "Access Levels"
  static const String adaptyAccessLevelId = 'premium';

  // Placement ID as configured in Adapty dashboard → "Placements"
  static const String adaptyPlacementId = 'base-placement';

  // ─── Google Sign-In ────────────────────────────────────────────────────────
  // Web Client ID from Google Cloud Console → APIs & Services → Credentials
  // (Use the "Web application" OAuth 2.0 client ID, NOT the Android one)
  static String get googleWebClientId =>
      dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';
}
