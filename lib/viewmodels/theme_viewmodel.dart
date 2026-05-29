import 'package:flutter/material.dart';
import 'package:children_stories/app/theme/app_colors.dart';

class ThemeViewModel extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  ThemeViewModel() {
    _updateAppColors();
  }

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  void toggleTheme() {
    if (isDarkMode) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    _updateAppColors();
    notifyListeners();
  }

  void _updateAppColors() {
    AppColors.current = isDarkMode ? AppColors.darkScheme : AppColors.lightScheme;
  }

  void updateSystemBrightness(Brightness brightness) {
    if (_themeMode == ThemeMode.system) {
      _updateAppColors();
      notifyListeners();
    }
  }
}
