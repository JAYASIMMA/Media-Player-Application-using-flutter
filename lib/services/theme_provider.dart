import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      // In a real app, you might want to check the platform dispatcher here,
      // but for simple toggling logic, we can just rely on the UI to update based on system.
      // However, for the 'isDark' boolean check sometimes used in UI, we might need context.
      // For now, let's just return false if system, or handle it where used.
      // But typically, 'isDarkMode' helper is better derived from context.
      return _themeMode == ThemeMode.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}
