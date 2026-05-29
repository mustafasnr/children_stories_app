import 'package:flutter/material.dart';

class AppColorScheme {
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color accent;
  final Color accentLight;
  final Color premium;
  final Color premiumLight;
  final Color premiumDark;
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color success;
  final Color error;

  AppColorScheme({
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.accent,
    required this.accentLight,
    required this.premium,
    required this.premiumLight,
    required this.premiumDark,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.success,
    required this.error,
  });
}

class AppColors {
  AppColors._();

  static final AppColorScheme lightScheme = AppColorScheme(
    primary: const Color(0xFF6844C7),       // Magic Purple
    primaryLight: const Color(0xFF9D7BFF),  // Magic Purple Light
    primaryDark: const Color(0xFF320085),   // Magic Purple Dark
    accent: const Color(0xFF8D4F04),        // Sunset Orange
    accentLight: const Color(0xFFFEAC5F),   // Sunset Orange Light
    premium: const Color(0xFFF59E0B),       // Amber Gold
    premiumLight: const Color(0xFFFCD34D),
    premiumDark: const Color(0xFFD97706),
    background: const Color(0xFFFAF7F0),    // Vanilla Cream (cozy paper feel)
    surface: const Color(0xFFFDF7FF),       // Whimsical surface tint
    surfaceVariant: const Color(0xFFE7DFF1),// Whimsical surface variant
    textPrimary: const Color(0xFF1D1A26),   // Deep Plum (soft dark)
    textSecondary: const Color(0xFF494553), // Medium Plum
    textHint: const Color(0xFF7A7485),      // Warm Outline Grey
    success: const Color(0xFF146C47),       // Leafy Green
    error: const Color(0xFFBA1A1A),         // Soft Error Red
  );

  static final AppColorScheme darkScheme = AppColorScheme(
    primary: const Color(0xFF8B5CF6),       // Premium Violet
    primaryLight: const Color(0xFFA78BFA),  // Premium Violet Light
    primaryDark: const Color(0xFF5B21B6),   // Premium Violet Dark
    accent: const Color(0xFFFEB877),        // Whimsical soft orange
    accentLight: const Color(0xFFFCDCC1),
    premium: const Color(0xFFF59E0B),
    premiumLight: const Color(0xFFFCD34D),
    premiumDark: const Color(0xFFD97706),
    background: const Color(0xFF2D2A3E),    // Deep Midnight Plum
    surface: const Color(0xFF37334C),       // Slightly lighter plum for cards
    surfaceVariant: const Color(0xFF494553),
    textPrimary: const Color(0xFFF5EEFF),   // Warm off-white
    textSecondary: const Color(0xFFCBC3D5), // Soft lavender grey
    textHint: const Color(0xFF7A7485),
    success: const Color(0xFF87D7AA),       // Whimsical soft green
    error: const Color(0xFFFFB4AB),         // Soft dark-theme error red
  );

  static AppColorScheme current = lightScheme;

  // Dynamic getters for standard app colors
  static Color get primary => current.primary;
  static Color get primaryLight => current.primaryLight;
  static Color get primaryDark => current.primaryDark;

  static Color get accent => current.accent;
  static Color get accentLight => current.accentLight;

  static Color get premium => current.premium;
  static Color get premiumLight => current.premiumLight;
  static Color get premiumDark => current.premiumDark;

  static Color get background => current.background;
  static Color get surface => current.surface;
  static Color get surfaceVariant => current.surfaceVariant;

  static Color get textPrimary => current.textPrimary;
  static Color get textSecondary => current.textSecondary;
  static Color get textHint => current.textHint;

  static Color get success => current.success;
  static Color get error => current.error;

  // Gradient palette for story covers (no image)
  static final List<List<Color>> _coverGradients = [
    [const Color(0xFF6C4AB6), const Color(0xFF9B72E8)],
    [const Color(0xFFFF7043), const Color(0xFFFFAB91)],
    [const Color(0xFF26A69A), const Color(0xFF80CBC4)],
    [const Color(0xFFEC407A), const Color(0xFFF48FB1)],
    [const Color(0xFF42A5F5), const Color(0xFF90CAF9)],
    [const Color(0xFF66BB6A), const Color(0xFFA5D6A7)],
    [const Color(0xFFAB47BC), const Color(0xFFCE93D8)],
    [const Color(0xFFFFA726), const Color(0xFFFFCC80)],
  ];

  static LinearGradient coverGradient(String storyId) {
    final hash = storyId.codeUnits.fold(0, (a, b) => a + b);
    final pair = _coverGradients[hash % _coverGradients.length];
    return LinearGradient(
      colors: pair,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient get primaryGradient => LinearGradient(
        colors: [primary, primaryLight],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get splashGradient => LinearGradient(
        colors: [
          current == darkScheme ? const Color(0xFF1D1B28) : const Color(0xFF2D1B6E),
          primary,
          primaryLight
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get premiumGradient => LinearGradient(
        colors: [premiumDark, premium, premiumLight],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}
