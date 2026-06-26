import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  bool _isLoggedIn = false;
  bool _isGuest = false;
  String? _name;
  String? _email;
  String _subscriptionType = 'Basic'; // 'Basic', 'Plus', 'Pro'

  bool get isLoggedIn => _isLoggedIn;
  bool get isGuest => _isGuest;
  String? get name => _isGuest ? 'Guest User' : (_name ?? 'Student');
  String? get email => _isGuest ? 'guest@studycards.app' : (_email ?? 'student@studycards.app');
  String get subscriptionType => _subscriptionType;

  AuthProvider() {
    loadAuthSession();
  }

  /// Initialize auth state from local storage.
  Future<void> loadAuthSession() async {
    await Future.delayed(Duration.zero);
    final authData = await _storageService.loadAuth();
    if (authData != null) {
      _isLoggedIn = (authData['isLoggedIn'] as bool?) ?? false;
      _isGuest = (authData['isGuest'] as bool?) ?? false;
      _name = authData['name'] as String?;
      _email = authData['email'] as String?;
      _subscriptionType = (authData['subscriptionType'] as String?) ?? 'Basic';
      notifyListeners();
    }
  }

  /// Helper to save auth state to storage.
  Future<void> _saveAuthSession() async {
    await _storageService.saveAuth({
      'isLoggedIn': _isLoggedIn,
      'isGuest': _isGuest,
      'name': _name,
      'email': _email,
      'subscriptionType': _subscriptionType,
    });
  }

  /// Mock login method.
  Future<bool> login(String email, String password) async {
    // Basic validation
    if (email.trim().isEmpty || password.trim().isEmpty) return false;

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    _isLoggedIn = true;
    _isGuest = false;
    _email = email.trim();
    // Default name if match is not standard
    final prefix = _email!.split('@')[0];
    _name = prefix[0].toUpperCase() + prefix.substring(1);
    
    // Default sub to Pro for mock demo standard, or keep Basic
    _subscriptionType = 'Pro'; 

    await _saveAuthSession();
    notifyListeners();
    return true;
  }

  /// Mock signup method.
  Future<bool> signUp(String name, String email, String password) async {
    if (name.trim().isEmpty || email.trim().isEmpty || password.trim().isEmpty) return false;

    await Future.delayed(const Duration(milliseconds: 600));

    _isLoggedIn = true;
    _isGuest = false;
    _name = name.trim();
    _email = email.trim();
    _subscriptionType = 'Basic';

    await _saveAuthSession();
    notifyListeners();
    return true;
  }

  /// Guest access mode.
  Future<void> continueAsGuest() async {
    _isLoggedIn = true;
    _isGuest = true;
    _name = 'Guest Student';
    _email = 'guest@studycards.app';
    _subscriptionType = 'Basic';

    await _saveAuthSession();
    notifyListeners();
  }

  /// Logs out of mock session and resets states.
  Future<void> logout() async {
    _isLoggedIn = false;
    _isGuest = false;
    _name = null;
    _email = null;
    _subscriptionType = 'Basic';
    await _storageService.clearAuth();
    notifyListeners();
  }

  /// Update subscription tier.
  Future<void> changeSubscription(String type) async {
    if (type == 'Basic' || type == 'Plus' || type == 'Pro') {
      _subscriptionType = type;
      await _saveAuthSession();
      notifyListeners();
    }
  }

  /// Mock forgot password handler.
  Future<bool> resetPassword(String email) async {
    if (email.trim().isEmpty) return false;
    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }
}
