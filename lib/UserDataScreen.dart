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
                child:
                    userData['user'] is Map
                        ? ListView(
                          children:
                              (userData['user'] as Map).entries.map((entry) {
                                return ListTile(
                                  title: Text('${entry.key}'),
                                  subtitle: Text('${entry.value}'),
                                );
                              }).toList(),
                        )
                        : Center(child: Text(userData.toString())),
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
