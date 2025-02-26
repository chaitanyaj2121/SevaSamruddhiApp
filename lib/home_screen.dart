import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'customer_list_screen.dart';
import 'AddCustomerScreen.dart';
import 'dashboard_screen.dart'; // ✅ Import DashboardScreen
import './widgets/smartserve_header.dart';
import 'notifications_screen.dart'; // ✅ Import NotificationsScreen
import 'config.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  Future<List<dynamic>> fetchCustomers() async {
    final response = await http.get(Uri.parse(APIConfig.customersUrl));
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey[200]!, Colors.grey[100]!],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 30),
              _buildHeader(),
              const SizedBox(height: 40),
              Expanded(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: 4,
                  separatorBuilder:
                      (context, index) => const SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    return _buildFeatureCard(context, index, fetchCustomers);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCustomerScreen()),
          );
        },
        backgroundColor: Colors.purple,
        elevation: 8,
        child: const Icon(Icons.person_add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'SmartServe Manager',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Manage your restaurant operations',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    int index,
    Future<List<dynamic>> Function() fetchCustomers,
  ) {
    final features = [
      {
        'title': 'Customers',
        'icon': Icons.people_alt_rounded,
        'color': Colors.blue,
        'action': fetchCustomers,
      },
      {
        'title': 'Dashboard',
        'icon': Icons.analytics_rounded,
        'color': Colors.green,
        'action': null,
      },
      {
        'title': 'Notifications',
        'icon': Icons.notifications_active_rounded,
        'color': Colors.orange,
        'action': null,
      },
      {
        'title': 'Reports',
        'icon': Icons.assignment_rounded,
        'color': Colors.purple,
        'action': null,
      },
    ];
    final feature = features[index];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _handleFeatureTap(context, feature),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (feature['color'] as Color).withOpacity(0.9),
                (feature['color'] as Color).withOpacity(0.7),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                top: -30,
                child: Icon(
                  feature['icon'] as IconData,
                  size: 120,
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      feature['icon'] as IconData,
                      size: 32,
                      color: Colors.white,
                    ),
                    const Spacer(),
                    Text(
                      feature['title'] as String,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 2,
                            color: Colors.black26,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleFeatureTap(BuildContext context, Map<String, dynamic> feature) {
    if (feature['title'] == 'Dashboard') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    } else if (feature['title'] == 'Notifications') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NotificationsScreen()),
      );
    } else if (feature['action'] != null) {
      _handleFetchAction(
        context,
        feature['action'] as Future<List<dynamic>> Function(),
      );
    }
  }

  void _handleFetchAction(
    BuildContext context,
    Future<List<dynamic>> Function() fetchFunction,
  ) async {
    try {
      final customers = await fetchFunction();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CustomerListScreen(customers: customers),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
