import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF6C4AB6);
  static const Color primaryLight = Color(0xFF9B72E8);
  static const Color primaryDark = Color(0xFF4A2E8C);

  static const Color accent = Color(0xFFFF7043);
  static const Color accentLight = Color(0xFFFF9A7A);

  static const Color premium = Color(0xFFF59E0B);
  static const Color premiumLight = Color(0xFFFCD34D);
  static const Color premiumDark = Color(0xFFD97706);

  static const Color background = Color(0xFFFFF8F3);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F0FF);

  static const Color textPrimary = Color(0xFF1A1035);
  static const Color textSecondary = Color(0xFF6B6B8A);
  static const Color textHint = Color(0xFFAEAEC2);

  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);

  // Gradient palette for story covers (no image)
  static const List<List<Color>> _coverGradients = [
    [Color(0xFF6C4AB6), Color(0xFF9B72E8)],
    [Color(0xFFFF7043), Color(0xFFFFAB91)],
    [Color(0xFF26A69A), Color(0xFF80CBC4)],
    [Color(0xFFEC407A), Color(0xFFF48FB1)],
    [Color(0xFF42A5F5), Color(0xFF90CAF9)],
    [Color(0xFF66BB6A), Color(0xFFA5D6A7)],
    [Color(0xFFAB47BC), Color(0xFFCE93D8)],
    [Color(0xFFFFA726), Color(0xFFFFCC80)],
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

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C4AB6), Color(0xFF9B72E8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF2D1B6E), Color(0xFF6C4AB6), Color(0xFF9B72E8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFFD97706), Color(0xFFF59E0B), Color(0xFFFCD34D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
