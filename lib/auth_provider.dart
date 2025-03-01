import 'package:flutter/material.dart';
import 'auth_helper.dart'; // Update the path as needed

class AuthProvider with ChangeNotifier {
  Map<String, dynamic>? _authData;
  bool _isLoading = true;

  // Getter for loading state (in case you want to show a loading indicator)
  bool get isLoading => _isLoading;

  // Getter for auth data
  Map<String, dynamic>? get authData => _authData;

  // Check if user is logged in and token is valid
  bool get isLoggedIn =>
      _authData != null &&
      _authData!.isNotEmpty &&
      AuthHelper.isTokenValid({'timestamp': _authData!['timestamp'] ?? 0});

  // Constructor: load saved auth data on initialization
  AuthProvider() {
    loadAuthData();
  }

  // Load auth data from persistent storage using AuthHelper
  Future<void> loadAuthData() async {
    final data = await AuthHelper.getAuthData();
    if (data != null && AuthHelper.isTokenValid(data)) {
      // Format the data as needed. Here we assume data has keys 'token', 'uid', and 'timestamp'
      _authData = {
        'token': data['token'],
        'user': {'uid': data['uid']},
        'timestamp': data['timestamp'],
      };
    } else {
      _authData = null;
    }
    _isLoading = false;
    notifyListeners();
  }

  // Save auth data using AuthHelper and update provider state
  Future<void> setAuthData(Map<String, dynamic> data) async {
    // data is expected to have 'token', 'user':{'uid': ...}, and optionally 'timestamp'
    await AuthHelper.saveAuthData(data['token'], data['user']['uid']);
    // For consistency, add a timestamp here as well:
    data['timestamp'] = DateTime.now().millisecondsSinceEpoch;
    _authData = data;
    notifyListeners();
  }

  Future<void> logout() async {
    await removeAuthData();
  }

  // Clear auth data using AuthHelper and update provider state
  Future<void> removeAuthData() async {
    await AuthHelper.clearAuthData();
    _authData = null;
    notifyListeners();
  }
}
