import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isWinterMode = false;
  bool get isWinterMode => _isWinterMode;

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isWinterMode = prefs.getBool('isWinterMode') ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isWinterMode = !_isWinterMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isWinterMode', _isWinterMode);
    notifyListeners();
  }

  // Light theme colors - Clean and minimal
  static const Color lightPrimary = Color(0xFF3B82F6); // Blue 500
  static const Color lightSecondary = Color(0xFF6366F1); // Indigo 500
  static const Color lightAccent = Color(0xFF8B5CF6); // Violet 500
  static const Color lightBackground = Color(0xFFFAFAFA); // Neutral 50
  static const Color lightSurface = Color(0xFFFFFFFF); // White
  static const Color lightSurfaceVariant = Color(0xFFF5F5F5); // Neutral 100
  static const Color lightText = Color(0xFF171717); // Neutral 900
  static const Color lightTextSecondary = Color(0xFF737373); // Neutral 500
  static const Color lightTextTertiary = Color(0xFFA3A3A3); // Neutral 400
  static const Color lightBorder = Color(0xFFE5E5E5); // Neutral 200
  static const Color lightError = Color(0xFFEF4444); // Red 500
  static const Color lightSuccess = Color(0xFF22C55E); // Green 500

  // Dark theme colors - Clean and minimal
  static const Color darkPrimary = Color(0xFF60A5FA); // Blue 400
  static const Color darkSecondary = Color(0xFF818CF8); // Indigo 400
  static const Color darkAccent = Color(0xFFA78BFA); // Violet 400
  static const Color darkBackground = Color(0xFF171717); // Neutral 900
  static const Color darkSurface = Color(0xFF262626); // Neutral 800
  static const Color darkSurfaceVariant = Color(0xFF404040); // Neutral 700
  static const Color darkText = Color(0xFFFAFAFA); // Neutral 50
  static const Color darkTextSecondary = Color(0xFFD4D4D4); // Neutral 300
  static const Color darkTextTertiary = Color(0xFFA3A3A3); // Neutral 400
  static const Color darkBorder = Color(0xFF525252); // Neutral 600
  static const Color darkError = Color(0xFFF87171); // Red 400
  static const Color darkSuccess = Color(0xFF4ADE80); // Green 400

  Color get primaryColor => _isWinterMode ? darkPrimary : lightPrimary;
  Color get secondaryColor => _isWinterMode ? darkSecondary : lightSecondary;
  Color get accentColor => _isWinterMode ? darkAccent : lightAccent;
  Color get backgroundColor => _isWinterMode ? darkBackground : lightBackground;
  Color get surfaceColor => _isWinterMode ? darkSurface : lightSurface;
  Color get surfaceVariantColor =>
      _isWinterMode ? darkSurfaceVariant : lightSurfaceVariant;
  Color get textColor => _isWinterMode ? darkText : lightText;
  Color get textSecondaryColor =>
      _isWinterMode ? darkTextSecondary : lightTextSecondary;
  Color get textTertiaryColor =>
      _isWinterMode ? darkTextTertiary : lightTextTertiary;
  Color get borderColor => _isWinterMode ? darkBorder : lightBorder;
  Color get errorColor => _isWinterMode ? darkError : lightError;
  Color get successColor => _isWinterMode ? darkSuccess : lightSuccess;

  String get themeName => _isWinterMode ? 'Kış' : 'Yaz';
  String get themeIcon => _isWinterMode ? '❄️' : '☀️';
}
