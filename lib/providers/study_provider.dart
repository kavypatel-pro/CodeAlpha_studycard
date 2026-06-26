import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import '../models/category.dart';
import '../models/study_stats.dart';
import '../services/storage_service.dart';
import '../services/flashcard_api_service.dart';

class StudyProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final FlashcardApiService _apiService = FlashcardApiService();

  List<Flashcard> _flashcards = []; // Local (custom/favorited) cards
  List<Category> _categories = [];
  StudyStats _stats = StudyStats();
  bool _isLoading = true;

  // API Flashcards state
  List<Flashcard> _apiFlashcards = [];
  bool _apiLoading = false;
  String? _apiError;
  bool _hasFetchedApi = false;

  // Search & Filter state
  String _searchQuery = '';
  String? _selectedCategory;
  bool _showFavoritesOnly = false;

  List<Flashcard> get flashcards => _flashcards;
  List<Category> get categories => _categories;
  StudyStats get stats => _stats;
  bool get isLoading => _isLoading;

  // API getters
  List<Flashcard> get apiFlashcards => _apiFlashcards;
  bool get apiLoading => _apiLoading;
  String? get apiError => _apiError;
  bool get hasFetchedApi => _hasFetchedApi;

  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  bool get showFavoritesOnly => _showFavoritesOnly;

  StudyProvider() {
    _initData();
  }

  /// Initial load of all stored items
  Future<void> _initData() async {
    // Wait for constructor to finish and tree to mount
    await Future.delayed(Duration.zero);

    _flashcards = await _storageService.loadFlashcards();
    _categories = await _storageService.loadCategories();
    _stats = await _storageService.loadStats();

    _isLoading = false;
    notifyListeners();
  }

  // ================= API OPERATIONS =================

  /// Fetches flashcards from the Google Gemini API
  Future<void> fetchApiFlashcards() async {
    _apiLoading = true;
    _apiError = null;
    notifyListeners();

    try {
      final fetchedCards = await _apiService.fetchFlashcards();
      
      // Sync favorite state with locally favorited cards
      _apiFlashcards = fetchedCards.map((card) {
        final isFav = _flashcards.any((localCard) => 
          localCard.id == card.id || 
          localCard.question.trim().toLowerCase() == card.question.trim().toLowerCase()
        );
        return card.copyWith(isFavorite: isFav);
      }).toList();

      _hasFetchedApi = true;
      _apiError = null;
    } catch (e) {
      _apiError = e.toString().replaceAll('Exception:', '').trim();
    } finally {
      _apiLoading = false;
      notifyListeners();
    }
  }

  // ================= SEARCH & FILTERING =================

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void selectCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void toggleFavoritesFilter() {
    _showFavoritesOnly = !_showFavoritesOnly;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _showFavoritesOnly = false;
    notifyListeners();
  }

  /// Returns the filtered locally stored flashcards
  List<Flashcard> get filteredFlashcards {
    return _flashcards.where((card) {
      final matchesSearch = card.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          card.answer.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesCategory = _selectedCategory == null || card.category == _selectedCategory;
      final matchesFavorite = !_showFavoritesOnly || card.isFavorite;

      return matchesSearch && matchesCategory && matchesFavorite;
    }).toList();
  }

  /// Returns the filtered API flashcards for the Home/Study Screen
  List<Flashcard> get filteredApiFlashcards {
    return _apiFlashcards.where((card) {
      final matchesSearch = card.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          card.answer.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesCategory = _selectedCategory == null || card.category == _selectedCategory;
      final matchesFavorite = !_showFavoritesOnly || card.isFavorite;

      return matchesSearch && matchesCategory && matchesFavorite;
    }).toList();
  }

  // ================= FLASHCARDS CRUD =================

  Future<void> addFlashcard({
    required String question,
    required String answer,
    required String category,
  }) async {
    final newCard = Flashcard(
      id: 'card-${DateTime.now().millisecondsSinceEpoch}',
      question: question.trim(),
      answer: answer.trim(),
      category: category,
      createdAt: DateTime.now(),
    );

    _flashcards.add(newCard);
    await _storageService.saveFlashcards(_flashcards);
    notifyListeners();
  }

  Future<void> updateFlashcard(Flashcard updatedCard) async {
    final index = _flashcards.indexWhere((c) => c.id == updatedCard.id);
    if (index != -1) {
      _flashcards[index] = updatedCard;
      await _storageService.saveFlashcards(_flashcards);
      notifyListeners();
    }
  }

  /// Toggles favorite state. Works on both local and API cards, persistence handled automatically.
  Future<void> toggleFavorite(String cardId) async {
    // 1. Check if the card is in the local list
    final localIndex = _flashcards.indexWhere((c) => c.id == cardId);
    
    // 2. Check if the card is in the API list
    final apiIndex = _apiFlashcards.indexWhere((c) => c.id == cardId);

    if (apiIndex != -1) {
      // It's an API card
      final card = _apiFlashcards[apiIndex];
      final newFavState = !card.isFavorite;
      _apiFlashcards[apiIndex] = card.copyWith(isFavorite: newFavState);

      if (newFavState) {
        // Add to local database as a favorite
        final existsLocally = _flashcards.any((c) => c.id == card.id);
        if (!existsLocally) {
          _flashcards.add(card.copyWith(isFavorite: true, id: card.id));
        }
      } else {
        // Remove from local database
        _flashcards.removeWhere((c) => c.id == card.id);
      }
      await _storageService.saveFlashcards(_flashcards);
    } else if (localIndex != -1) {
      // It's a local custom card
      final card = _flashcards[localIndex];
      final newFavState = !card.isFavorite;
      
      // If it's a favorited API card and we are unfavoriting it, delete it from local list
      if (!newFavState && card.id.startsWith('card-') == false) {
        _flashcards.removeAt(localIndex);
        // Also sync state with the API list if it happens to be loaded
        final apiIdx = _apiFlashcards.indexWhere((c) => c.id == card.id);
        if (apiIdx != -1) {
          _apiFlashcards[apiIdx] = _apiFlashcards[apiIdx].copyWith(isFavorite: false);
        }
      } else {
        _flashcards[localIndex] = card.copyWith(isFavorite: newFavState);
      }
      await _storageService.saveFlashcards(_flashcards);
    }

    notifyListeners();
  }

  Future<void> deleteFlashcard(String cardId) async {
    _flashcards.removeWhere((c) => c.id == cardId);
    // Also sync the API card list if it contains it
    final apiIndex = _apiFlashcards.indexWhere((c) => c.id == cardId);
    if (apiIndex != -1) {
      _apiFlashcards[apiIndex] = _apiFlashcards[apiIndex].copyWith(isFavorite: false);
    }
    await _storageService.saveFlashcards(_flashcards);
    notifyListeners();
  }

  // ================= CATEGORIES CRUD =================

  Future<void> addCategory(String name, int iconCode, int colorValue) async {
    final newCat = Category(
      id: 'cat-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      iconCode: iconCode,
      colorValue: colorValue,
    );

    _categories.add(newCat);
    await _storageService.saveCategories(_categories);
    notifyListeners();
  }

  Future<void> updateCategory(Category updatedCategory, String oldName) async {
    final index = _categories.indexWhere((c) => c.id == updatedCategory.id);
    if (index != -1) {
      _categories[index] = updatedCategory;
      await _storageService.saveCategories(_categories);

      // If category name changed, update all corresponding flashcards
      if (oldName != updatedCategory.name) {
        _flashcards = _flashcards.map((card) {
          if (card.category == oldName) {
            return card.copyWith(category: updatedCategory.name);
          }
          return card;
        }).toList();
        await _storageService.saveFlashcards(_flashcards);
      }
      notifyListeners();
    }
  }

  Future<void> deleteCategory(String id, String categoryName) async {
    _categories.removeWhere((c) => c.id == id);
    await _storageService.saveCategories(_categories);

    // Reassign flashcards of this deleted category to 'General Knowledge'
    _flashcards = _flashcards.map((card) {
      if (card.category == categoryName) {
        return card.copyWith(category: 'General Knowledge');
      }
      return card;
    }).toList();
    await _storageService.saveFlashcards(_flashcards);
    notifyListeners();
  }

  // ================= STUDY SESSION STATS =================

  Future<void> completeStudySession(int cardsReviewedCount) async {
    final todayStr = DateTime.now().toIso8601String().split('T')[0];

    int newStreak = _stats.streak;
    final lastDate = _stats.lastStudyDate;

    if (lastDate == null) {
      newStreak = 1;
    } else {
      final difference = DateTime.now().difference(DateTime.parse(lastDate)).inDays;
      if (difference == 1) {
        newStreak += 1;
      } else if (difference > 1) {
        newStreak = 1; // Reset streak
      }
    }

    final dates = List<String>.from(_stats.datesStudied);
    if (!dates.contains(todayStr)) {
      dates.add(todayStr);
    }

    final newMasteredCount = _stats.cardsMastered + (cardsReviewedCount ~/ 4).clamp(0, cardsReviewedCount);

    _stats = _stats.copyWith(
      totalSessions: _stats.totalSessions + 1,
      streak: newStreak,
      lastStudyDate: todayStr,
      datesStudied: dates,
      cardsReviewed: _stats.cardsReviewed + cardsReviewedCount,
      cardsMastered: newMasteredCount,
    );

    await _storageService.saveStats(_stats);
    notifyListeners();
  }
}
