import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'customer_list_screen.dart'; // Import the new screen

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  Future<List<dynamic>> fetchCustomers() async {
    final response = await http.get(
      Uri.parse('http://192.168.48.11:4000/customers'),
    ); // Replace with your API URL

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(
        response.body,
      ); // Ensure decoding as Map
      if (data['success'] == true && data.containsKey('customers')) {
        return data['customers']; // Extract 'customers' array
      } else {
        throw Exception('Invalid response format');
      }
    } else {
      throw Exception('Failed to load customers');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home Screen',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 5,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildButton(
                context,
                'Customers',
                Icons.people,
                Colors.blue,
                fetchCustomers, // Pass function reference
              ),
              const SizedBox(height: 20),
              _buildButton(
                context,
                'Dashboard',
                Icons.dashboard,
                Colors.green,
                null,
              ),
              const SizedBox(height: 20),
              _buildButton(
                context,
                'Notifications',
                Icons.notifications,
                Colors.orange,
                null,
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.grey[200],
    );
  }

  Widget _buildButton(
    BuildContext context,
    String text,
    IconData icon,
    Color color,
    Future<List<dynamic>> Function()?
    fetchFunction, // Accept a function reference
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: color,
          elevation: 5,
          shadowColor: Colors.black45,
        ),
        onPressed: () async {
          if (fetchFunction != null) {
            try {
              List<dynamic> customers =
                  await fetchFunction(); // Invoke function
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => CustomerListScreen(customers: customers),
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error fetching customers: $e')),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$text Button Pressed'),
                backgroundColor: color,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
