import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  ThemeMode _themeMode = ThemeMode.light;
  String _colorTheme = 'purple'; // 'purple', 'sunset', 'ocean', 'forest'
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'en';

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  String get colorTheme => _colorTheme;
  bool get notificationsEnabled => _notificationsEnabled;
  String get selectedLanguage => _selectedLanguage;

  ThemeProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await Future.delayed(Duration.zero);
    final themeStr = await _storageService.loadTheme();
    if (themeStr == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (themeStr == 'light') {
      _themeMode = ThemeMode.light;
    } else {
      // It's a custom theme name
      _themeMode = ThemeMode.light;
      _colorTheme = themeStr;
    }

    _notificationsEnabled = await _storageService.loadNotificationsEnabled();
    _selectedLanguage = await _storageService.loadLanguage();
    notifyListeners();
  }

  /// Toggle between Light and Dark mode
  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    await _storageService.saveTheme(isDark ? 'dark' : 'light');
    notifyListeners();
  }

  /// Change the color scheme preset (e.g. sunset, ocean, forest)
  Future<void> setColorTheme(String newTheme) async {
    _colorTheme = newTheme;
    await _storageService.saveTheme(newTheme);
    notifyListeners();
  }

  /// Toggle notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    await _storageService.saveNotificationsEnabled(enabled);
    notifyListeners();
  }

  /// Set app language
  Future<void> setLanguage(String langCode) async {
    _selectedLanguage = langCode;
    await _storageService.saveLanguage(langCode);
    notifyListeners();
  }

  /// Get the active seed color based on selected color theme
  Color get seedColor {
    switch (_colorTheme) {
      case 'sunset':
        return Colors.deepOrange;
      case 'ocean':
        return Colors.teal;
      case 'forest':
        return const Color(0xFF10B981); // Fallback to green
      case 'purple':
      default:
        return Colors.deepPurple;
    }
  }

  Color get emerald {
    return const Color(0xFF10B981);
  }

  /// Generates the ThemeData for the application.
  ThemeData getThemeData(bool dark) {
    Color seed = seedColor;
    if (_colorTheme == 'forest') {
      seed = const Color(0xFF10B981);
    }
    
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: dark ? Brightness.dark : Brightness.light,
      surface: dark ? const Color(0xFF0F0E17) : const Color(0xFFFAF9FC),
      primary: seed,
      surfaceContainer: dark ? const Color(0xFF1E1C2A) : Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark ? const Color(0xFF0F0E17) : const Color(0xFFFAF9FC),
      cardTheme: CardThemeData(
        color: dark ? const Color(0xFF1E1C2A) : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: dark ? const Color(0xFF2E2C3D) : const Color(0xFFEEEEEE),
            width: 1,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF1E1C2A) : const Color(0xFFF5F4F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: dark ? const Color(0xFF2E2C3D) : const Color(0xFFEEEEEE), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: seed, width: 2),
        ),
      ),
    );
  }
}
