import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  Map<String, dynamic>? _authData;

  Map<String, dynamic>? get authData => _authData;

  bool get isLoggedIn => _authData != null && _authData!.isNotEmpty;

  // Set user data after login
  void setAuthData(Map<String, dynamic> data) {
    _authData = data;
    notifyListeners();
  }

  // Remove user data on logout
  void removeAuthData() {
    _authData = null;
    notifyListeners();
  }
}
