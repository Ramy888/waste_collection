import 'package:flutter/material.dart';

import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  // Dummy user credentials
  static const String validEmail = "demo@wastecollection.com";
  static const String validPassword = "Demo@123";

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    if (email == validEmail && password == validPassword) {
      _user = UserModel(
        id: "1",
        email: validEmail,
        name: "Demo User",
        role: "team_leader",
        phoneNumber: "+1234567890",
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _error = "Invalid email or password";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    if (email == validEmail) {
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _error = "Email not found";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    required String phoneNumber,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    if (_user != null) {
      _user = UserModel(
        id: _user!.id,
        email: _user!.email,
        name: name,
        role: _user!.role,
        phoneNumber: phoneNumber,
        profileImage: _user!.profileImage,
      );
    }

    _isLoading = false;
    notifyListeners();
  }
}