class AppConstants {
  AppConstants._();

  // ─── Adapty ────────────────────────────────────────────────────────────────
  // Replace with your Adapty public API key from https://app.adapty.io/
  static const String adaptyPublicKey =
      'public_live_04OVLs4r.EYQhVo3UXxbSP519Mp8s';

  // Access level ID as configured in Adapty dashboard → "Access Levels"
  static const String adaptyAccessLevelId = 'premium';

  // Placement ID as configured in Adapty dashboard → "Placements"
  static const String adaptyPlacementId = 'base-placement';

  // ─── Google Sign-In ────────────────────────────────────────────────────────
  // Web Client ID from Google Cloud Console → APIs & Services → Credentials
  // (Use the "Web application" OAuth 2.0 client ID, NOT the Android one)
  static const String googleWebClientId =
      '473679521746-rnchjk6ql4ig9u9kp11jtnm6vfgn6csp.apps.googleusercontent.com';

  // ─── App info ──────────────────────────────────────────────────────────────
  static const String appName = 'Children Stories';
  static const String appTagline = 'Adventure in every page ✨';

  // ─── UI ────────────────────────────────────────────────────────────────────
  static const double cardRadius = 20.0;
  static const double buttonRadius = 16.0;
  static const double pagePadding = 20.0;
}
