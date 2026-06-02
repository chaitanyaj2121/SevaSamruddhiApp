import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

class AuthService {
  final String _url = APIConfig.loginUrl; // Ensure HTTPS

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // Log the request data
      print("Attempting login with Email: $email");

      final response = await http.post(
        Uri.parse(_url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email.trim(), // Use trimmed input to remove spaces
          'password': password.trim(),
        }),
      );

      // Log server response
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      // Check if response is empty before decoding
      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'No response from server. Please try again later.',
        };
      }

      // Parse the response
      final responseData = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData['success'] == true ||
            responseData.containsKey('token')) {
          return {
            'success': true,
            'message': 'Login successful',
            'data': responseData,
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Invalid credentials.',
          };
        }
      } else {
        return {
          'success': false,
          'message':
              responseData['message'] ?? 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }
}
