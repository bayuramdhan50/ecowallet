import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _user?.role == 'admin';
  bool get isClient => _user?.role == 'client';

  /// Initialize - Check if user is already logged in
  Future<void> initialize() async {
    try {
      _isLoading = true;
      // Don't call notifyListeners here to avoid build-time errors

      _user = await _authService.getSavedUser();

      _isLoading = false;
      // Safe to notify after await
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Register
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.register(
      name: name,
      email: email,
      password: password,
    );

    _isLoading = false;

    if (result['success']) {
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  /// Login
  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.login(email: email, password: password);

    _isLoading = false;

    if (result['success']) {
      _user = result['user'];
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  /// Refresh user data
  Future<void> refreshUser() async {
    final result = await _authService.getCurrentUser();

    if (result['success']) {
      _user = result['user'];
      notifyListeners();
    }
  }

  /// Logout
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
