// lib/helpers/auth_helper.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthHelper {
  static const _storage = FlutterSecureStorage();
  static const _prefsKey = 'auth_data';

  // Save authentication data
  static Future<void> saveAuthData(String token, String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      jsonEncode({
        'token': token,
        'uid': uid,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      }),
    );
  }

  // Retrieve authentication data
  static Future<Map<String, dynamic>?> getAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_prefsKey);
    return data != null ? jsonDecode(data) : null;
  }

  // Clear authentication data
  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }

  // In auth_helper.dart
  static bool isTokenValid(Map<String, dynamic>? data) {
    if (data == null) return false;
    final storedTime = DateTime.fromMillisecondsSinceEpoch(data['timestamp']);
    return DateTime.now().difference(storedTime) < const Duration(hours: 6);
  }
}
