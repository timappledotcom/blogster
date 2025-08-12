import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UbuntuAccentColor {
  orange(
    name: 'Ubuntu Orange',
    lightColor: Color(0xFFE95420),
    darkColor: Color(0xFFE95420),
    description: 'The classic Ubuntu orange',
  ),
  blue(
    name: 'Ubuntu Blue',
    lightColor: Color(0xFF0073E6),
    darkColor: Color(0xFF4A90E2),
    description: 'Calm and professional blue',
  ),
  green(
    name: 'Ubuntu Green',
    lightColor: Color(0xFF0E8420),
    darkColor: Color(0xFF26B344),
    description: 'Natural and sustainable green',
  ),
  purple(
    name: 'Ubuntu Purple',
    lightColor: Color(0xFF772953),
    darkColor: Color(0xFF9B4B73),
    description: 'Rich and creative purple',
  ),
  red(
    name: 'Ubuntu Red',
    lightColor: Color(0xFFDA4453),
    darkColor: Color(0xFFE74C3C),
    description: 'Bold and energetic red',
  ),
  teal(
    name: 'Ubuntu Teal',
    lightColor: Color(0xFF00A693),
    darkColor: Color(0xFF26B5A3),
    description: 'Modern and fresh teal',
  ),
  yellow(
    name: 'Ubuntu Yellow',
    lightColor: Color(0xFFE6B800),
    darkColor: Color(0xFFF39C12),
    description: 'Bright and optimistic yellow',
  ),
  pink(
    name: 'Ubuntu Pink',
    lightColor: Color(0xFFD33682),
    darkColor: Color(0xFFE91E63),
    description: 'Playful and vibrant pink',
  ),
  indigo(
    name: 'Ubuntu Indigo',
    lightColor: Color(0xFF5856D6),
    darkColor: Color(0xFF7986CB),
    description: 'Deep and thoughtful indigo',
  ),
  cyan(
    name: 'Ubuntu Cyan',
    lightColor: Color(0xFF00BCD4),
    darkColor: Color(0xFF26C6DA),
    description: 'Clear and refreshing cyan',
  );

  const UbuntuAccentColor({
    required this.name,
    required this.lightColor,
    required this.darkColor,
    required this.description,
  });

  final String name;
  final Color lightColor;
  final Color darkColor;
  final String description;

  Color getColor(bool isDark) => isDark ? darkColor : lightColor;
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  UbuntuAccentColor _accentColor = UbuntuAccentColor.orange;
  bool _isLoaded = false;

  ThemeMode get themeMode => _themeMode;
  UbuntuAccentColor get accentColor => _accentColor;
  bool get isLoaded => _isLoaded;

  bool get isDarkMode {
    return _themeMode == ThemeMode.dark;
  }

  bool get isLightMode {
    return _themeMode == ThemeMode.light;
  }

  bool get isSystemMode {
    return _themeMode == ThemeMode.system;
  }

  // Load theme settings from SharedPreferences
  Future<void> loadThemeSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Load theme mode
    final themeIndex = prefs.getInt('theme_mode') ?? ThemeMode.system.index;
    _themeMode = ThemeMode.values[themeIndex];

    // Load accent color
    final accentColorName =
        prefs.getString('accent_color') ?? UbuntuAccentColor.orange.name;
    _accentColor = UbuntuAccentColor.values.firstWhere(
      (color) => color.name == accentColorName,
      orElse: () => UbuntuAccentColor.orange,
    );

    _isLoaded = true;
    notifyListeners();
  }

  // Save theme settings to SharedPreferences
  Future<void> _saveThemeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', _themeMode.index);
    await prefs.setString('accent_color', _accentColor.name);
  }

  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _saveThemeSettings();
    notifyListeners();
  }

  void setAccentColor(UbuntuAccentColor color) async {
    _accentColor = color;
    await _saveThemeSettings();
    notifyListeners();
  }

  void toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.system;
    } else {
      _themeMode = ThemeMode.light;
    }
    await _saveThemeSettings();
    notifyListeners();
  }
}
