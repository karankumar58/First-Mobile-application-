// controllers/auth_controller.dart
import 'package:flutter/material.dart';
import '../enums/app_enums.dart';
import '../models/user_model.dart';

class AuthController extends ChangeNotifier {
  // Simulated in-memory user store
  static final Map<String, UserModel> _registeredUsers = {};

  // State
  AuthState _state = AuthState.idle;
  String? _errorMessage;
  UserModel? _currentUser;
  bool _rememberMe = false;

  // Getters
  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;
  bool get rememberMe => _rememberMe;

  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  Future<bool> register(UserModel user) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800)); // simulate async

    if (_registeredUsers.containsKey(user.email.toLowerCase())) {
      _state = AuthState.error;
      _errorMessage = 'An account with this email already exists.';
      notifyListeners();
      return false;
    }

    _registeredUsers[user.email.toLowerCase()] = user;
    _state = AuthState.success;
    notifyListeners();
    return true;
  }

  Future<bool> login(String email, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800)); // simulate async

    final user = _registeredUsers[email.toLowerCase()];
    if (user == null || user.password != password) {
      _state = AuthState.error;
      _errorMessage = 'Invalid email or password.';
      notifyListeners();
      return false;
    }

    _currentUser = user;
    _state = AuthState.success;
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    _state = AuthState.idle;
    _errorMessage = null;
    notifyListeners();
  }

  void resetState() {
    _state = AuthState.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
