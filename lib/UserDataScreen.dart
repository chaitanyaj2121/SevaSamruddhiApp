import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';

class UserDataScreen extends StatelessWidget {
  const UserDataScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Retrieve the current auth data from the AuthProvider.
    final authProvider = Provider.of<AuthProvider>(context);
    final userData = authProvider.authData;

    return Scaffold(
      appBar: AppBar(title: const Text('User Data')),
      body:
          userData != null
              ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display the user ID (assuming it exists as shown).
                    Text(
                      'User ID: ${userData['user']['uid']}',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 10),
                    // Optionally display more user details if available.
                    if (userData['user']['email'] != null)
                      Text(
                        'Email: ${userData['user']['email']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    // Add any additional fields you have in your user data.
                  ],
                ),
              )
              : const Center(
                child: Text(
                  'No user data available.',
                  style: TextStyle(fontSize: 18),
                ),
              ),
    );
  }
}
