import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Replace this URL with your backend URL
  final String _url = 'http://192.168.166.11:8080/login';

  // Login function
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // Make the POST request
      final response = await http.post(
        Uri.parse(_url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      // Check if the request was successful (any 2xx status code)
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Parse the response
        final responseData = json.decode(response.body);

        // Check if the response contains a success flag or token
        if (responseData['success'] == true || responseData['token'] != null) {
          return {
            'success': true,
            'message': 'Login successful',
            'data': responseData,
          };
        } else {
          return {
            'success': false,
            'message':
                responseData['message'] ??
                'Invalid credentials. Please try again.',
          };
        }
      } else {
        // Handle non-2xx status codes
        final errorResponse = json.decode(response.body);
        return {
          'success': false,
          'message':
              errorResponse['message'] ??
              'Invalid credentials. Please try again.',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'An error occurred here: $e'};
    }
  }
}
