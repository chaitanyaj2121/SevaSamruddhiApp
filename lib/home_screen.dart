import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'customer_list_screen.dart';
import 'AddCustomerScreen.dart';
import 'dashboard_screen.dart'; // ✅ Import DashboardScreen
import './widgets/smartserve_header.dart';
import 'notifications_screen.dart'; // ✅ Import NotificationsScreen

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  Future<List<dynamic>> fetchCustomers() async {
    final response = await http.get(
      Uri.parse('http://192.168.166.11:8080/customers'),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['success'] == true && data.containsKey('customers')) {
        return data['customers'];
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
      appBar: SmartServeHeader(),
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
                fetchCustomers,
              ),
              const SizedBox(height: 20),
              _buildButton(
                context,
                'Dashboard', // ✅ Navigates to Dashboard
                Icons.dashboard,
                Colors.green,
                null,
                navigateToDashboard: true,
              ),
              const SizedBox(height: 20),
              _buildButton(
                context,
                'Notifications',
                Icons.notifications,
                Colors.orange,
                null,
              ),
              const SizedBox(height: 20),
              _buildButton(
                context,
                'Add Customer',
                Icons.person_add,
                Colors.purple,
                null,
                isAddCustomer: true,
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
    Future<List<dynamic>> Function()? fetchFunction, {
    bool isAddCustomer = false,
    bool navigateToDashboard = false, // ✅ New flag for dashboard
  }) {
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
          if (isAddCustomer) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddCustomerScreen()),
            );
          } else if (navigateToDashboard) {
            // ✅ Navigate to DashboardScreen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DashboardScreen()),
            );
          } else if (text == 'Notifications') {
            // ✅ Navigate to NotificationsScreen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationsScreen(),
              ),
            );
          } else if (fetchFunction != null) {
            try {
              List<dynamic> customers = await fetchFunction();
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
