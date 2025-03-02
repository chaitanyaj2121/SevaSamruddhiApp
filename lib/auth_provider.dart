import 'package:flutter/material.dart';
import 'auth_helper.dart'; // Update the path as needed

class AuthProvider with ChangeNotifier {
  Map<String, dynamic>? _authData;
  bool _isLoading = true;

  bool get isLoading => _isLoading;

  Map<String, dynamic>? get authData => _authData;

  bool get isLoggedIn =>
      _authData != null &&
      _authData!.isNotEmpty &&
      AuthHelper.isTokenValid({'timestamp': _authData!['timestamp'] ?? 0});

  AuthProvider() {
    loadAuthData();
  }

  Future<void> loadAuthData() async {
    final data = await AuthHelper.getAuthData();
    if (data != null && AuthHelper.isTokenValid(data)) {
      _authData = {
        'token': data['token'],
        'user': {'uid': data['user']['uid'], 'fees': data['user']['fees']},
        'timestamp': data['timestamp'],
      };
    } else {
      _authData = null;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> setAuthData(Map<String, dynamic> data) async {
    await AuthHelper.saveAuthData(
      data['token'],
      data['user']['uid'],
      data['user']['fees'],
    );
    data['timestamp'] = DateTime.now().millisecondsSinceEpoch;
    _authData = data;
    notifyListeners();
  }

  Future<void> logout() async {
    await removeAuthData();
  }

  Future<void> removeAuthData() async {
    await AuthHelper.clearAuthData();
    _authData = null;
    notifyListeners();
  }
}
