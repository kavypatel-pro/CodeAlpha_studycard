import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/flashcard.dart';
import '../models/category.dart';
import '../models/study_stats.dart';

class StorageService {
  static const String _flashcardsKey = 'study_cards_list_v2';
  static const String _categoriesKey = 'study_cards_categories';
  static const String _statsKey = 'study_cards_stats';
  static const String _authKey = 'study_cards_auth';
  static const String _themeKey = 'study_cards_theme';
  static const String _notificationsKey = 'study_cards_notifications';
  static const String _languageKey = 'study_cards_language';

  // ================= FLASHCARDS STORAGE =================

  /// Loads flashcards from local storage.
  /// If no cards are found, saves and returns a default list of cards.
  Future<List<Flashcard>> loadFlashcards() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cardsJson = prefs.getString(_flashcardsKey);

    if (cardsJson == null || cardsJson.trim().isEmpty) {
      final defaultCards = [
        Flashcard(
          id: 'def-1',
          question: 'What is Flutter?',
          answer: 'Flutter is Google\'s portable UI toolkit for building beautiful, natively compiled applications for mobile, web, and desktop from a single codebase.',
          category: 'Programming',
          isFavorite: true,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        Flashcard(
          id: 'def-2',
          question: 'What is an atom?',
          answer: 'An atom is the basic unit of a chemical element, consisting of a nucleus of protons and neutrons, with electrons orbiting around it.',
          category: 'Science',
          isFavorite: false,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Flashcard(
          id: 'def-3',
          question: 'State the Pythagorean Theorem.',
          answer: 'In a right-angled triangle, the square of the hypotenuse (the side opposite the right angle) is equal to the sum of the squares of the other two sides: a² + b² = c².',
          category: 'Mathematics',
          isFavorite: true,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Flashcard(
          id: 'def-4',
          question: 'Who was the first President of the United States?',
          answer: 'George Washington, who served as president from 1789 to 1797.',
          category: 'History',
          isFavorite: false,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        Flashcard(
          id: 'def-5',
          question: 'Which planet is known as the Red Planet?',
          answer: 'Mars. It gets its reddish color from iron oxide (rust) on its surface.',
          category: 'General Knowledge',
          isFavorite: false,
          createdAt: DateTime.now(),
        ),
      ];
      await saveFlashcards(defaultCards);
      return defaultCards;
    }

    try {
      final List<dynamic> decodedList = jsonDecode(cardsJson) as List<dynamic>;
      return decodedList
          .map((item) => Flashcard.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Saves the list of flashcards.
  Future<void> saveFlashcards(List<Flashcard> flashcards) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> mappedList =
        flashcards.map((card) => card.toJson()).toList();
    await prefs.setString(_flashcardsKey, jsonEncode(mappedList));
  }

  // ================= CATEGORIES STORAGE =================

  /// Loads categories from local storage.
  /// If empty, saves and returns the default set of categories.
  Future<List<Category>> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final String? categoriesJson = prefs.getString(_categoriesKey);

    if (categoriesJson == null || categoriesJson.trim().isEmpty) {
      final defaultCategories = [
        Category(
          id: 'cat-programming',
          name: 'Programming',
          iconCode: 0xe17f, // Icons.code
          colorValue: 0xFF2196F3, // Colors.blue
        ),
        Category(
          id: 'cat-science',
          name: 'Science',
          iconCode: 0xe475, // Icons.science
          colorValue: 0xFF4CAF50, // Colors.green
        ),
        Category(
          id: 'cat-math',
          name: 'Mathematics',
          iconCode: 0xe2c6, // Icons.functions
          colorValue: 0xFFFF9800, // Colors.orange
        ),
        Category(
          id: 'cat-history',
          name: 'History',
          iconCode: 0xe314, // Icons.history
          colorValue: 0xFF795548, // Colors.brown
        ),
        Category(
          id: 'cat-gk',
          name: 'General Knowledge',
          iconCode: 0xe38c, // Icons.lightbulb_outline
          colorValue: 0xFFFFC107, // Colors.amber
        ),
      ];
      await saveCategories(defaultCategories);
      return defaultCategories;
    }

    try {
      final List<dynamic> decodedList = jsonDecode(categoriesJson) as List<dynamic>;
      return decodedList
          .map((item) => Category.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Saves categories.
  Future<void> saveCategories(List<Category> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> mappedList =
        categories.map((cat) => cat.toJson()).toList();
    await prefs.setString(_categoriesKey, jsonEncode(mappedList));
  }

  // ================= STATISTICS STORAGE =================

  /// Loads study stats.
  Future<StudyStats> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final String? statsJson = prefs.getString(_statsKey);

    if (statsJson == null || statsJson.trim().isEmpty) {
      return StudyStats(
        totalSessions: 3,
        streak: 2,
        lastStudyDate: DateTime.now().subtract(const Duration(days: 1)).toIso8601String().split('T')[0],
        datesStudied: [
          DateTime.now().subtract(const Duration(days: 2)).toIso8601String().split('T')[0],
          DateTime.now().subtract(const Duration(days: 1)).toIso8601String().split('T')[0],
        ],
        cardsReviewed: 25,
        cardsMastered: 8,
      );
    }

    try {
      return StudyStats.fromJson(jsonDecode(statsJson) as Map<String, dynamic>);
    } catch (e) {
      return StudyStats();
    }
  }

  /// Saves study stats.
  Future<void> saveStats(StudyStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_statsKey, jsonEncode(stats.toJson()));
  }

  // ================= AUTH STORAGE =================

  /// Loads authentication state (returns null if guest or logged out).
  Future<Map<String, dynamic>?> loadAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final String? authJson = prefs.getString(_authKey);
    if (authJson == null) return null;
    try {
      return jsonDecode(authJson) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Saves authentication state.
  Future<void> saveAuth(Map<String, dynamic> authData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authKey, jsonEncode(authData));
  }

  /// Clears authentication data (Logout).
  Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authKey);
  }

  // ================= GENERAL SETTINGS STORAGE =================

  /// Loads theme selection (options: 'light', 'dark', or customized theme name).
  Future<String> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey) ?? 'light';
  }

  /// Saves theme selection.
  Future<void> saveTheme(String themeName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, themeName);
  }

  /// Loads notifications state.
  Future<bool> loadNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsKey) ?? true;
  }

  /// Saves notifications state.
  Future<void> saveNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, enabled);
  }

  /// Loads selected language code.
  Future<String> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'en';
  }

  /// Saves selected language.
  Future<void> saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }
}
