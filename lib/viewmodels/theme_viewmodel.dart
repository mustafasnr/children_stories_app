import 'package:flutter/material.dart';
import 'package:children_stories/app/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeViewModel extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  bool _storySoundsEnabled = true;
  double _storyTextSizeStep = 5.0;

  ThemeMode get themeMode => _themeMode;
  bool get storySoundsEnabled => _storySoundsEnabled;
  double get storyTextSizeStep => _storyTextSizeStep;
  double get storyTextSize => 10.0 + _storyTextSizeStep * 2.0;

  ThemeViewModel() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool('is_dark') ?? false;
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      _storySoundsEnabled = prefs.getBool('story_sounds') ?? true;
      _storyTextSizeStep = prefs.getDouble('story_text_size_step') ?? 5.0;
      _updateAppColors();
      notifyListeners();
    } catch (e) {
      debugPrint('[ThemeVM] error loading settings: $e');
    }
  }

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
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

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    _updateAppColors();
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_dark', mode == ThemeMode.dark);
    } catch (e) {
      debugPrint('[ThemeVM] error saving theme: $e');
    }
  }

  Future<void> setStorySoundsEnabled(bool enabled) async {
    if (_storySoundsEnabled == enabled) return;
    _storySoundsEnabled = enabled;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('story_sounds', enabled);
    } catch (e) {
      debugPrint('[ThemeVM] error saving sounds setting: $e');
    }
  }

  void _updateAppColors() {
    AppColors.current = isDarkMode
        ? AppColors.darkScheme
        : AppColors.lightScheme;
  }

  void updateSystemBrightness(Brightness brightness) {
    if (_themeMode == ThemeMode.system) {
      _updateAppColors();
      notifyListeners();
    }
  }

  Future<void> setStoryTextSizeStep(double step) async {
    if (_storyTextSizeStep == step) return;
    _storyTextSizeStep = step;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('story_text_size_step', step);
    } catch (e) {
      debugPrint('[ThemeVM] error saving text size setting: $e');
    }
  }
}
