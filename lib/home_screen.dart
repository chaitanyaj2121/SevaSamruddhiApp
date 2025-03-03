import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'customer_list_screen.dart';
import 'AddCustomerScreen.dart';
import 'dashboard_screen.dart';
import 'profile.dart';
import 'notifications_screen.dart';
import 'config.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'login_screen.dart';
import 'about_help_screen.dart';

class HomeScreen extends StatelessWidget {
  final String uid;

  const HomeScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      toolbarHeight: 80,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade700, Colors.purple.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Flexible(
              child: Text(
                'SmartServe',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                await authProvider.logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.logout, color: Colors.white, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFFF5F5F5)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: 5,
                separatorBuilder:
                    (context, index) => const SizedBox(height: 15),
                itemBuilder: (context, index) {
                  return _buildFeatureCard(context, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddCustomerScreen()),
        );
      },
      icon: const Icon(Icons.person_add_alt_1, color: Colors.white, size: 20),
      label: const Text(
        'Add Customer',
        style: TextStyle(fontSize: 14, color: Colors.white),
      ),
      backgroundColor: Colors.purple,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome Back!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage restaurant operations',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, int index) {
    final features = [
      {
        'title': 'Customers',
        'icon': Icons.people_alt_rounded,
        'color': [Colors.blue.shade600, Colors.blue.shade400],
        'action': () {
          // Get messId before navigating to CustomerListScreen
          final authProvider = Provider.of<AuthProvider>(
            context,
            listen: false,
          );
          final messId = authProvider.authData?['user']['uid'];

          // Navigate to CustomerListScreen with messId
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CustomerListScreen(messId: messId),
            ),
          );
        },
      },
      {
        'title': 'Dashboard',
        'icon': Icons.analytics_rounded,
        'color': [Colors.green.shade600, Colors.green.shade400],
        'action':
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DashboardScreen()),
            ),
      },
      {
        'title': 'Notifications',
        'icon': Icons.notifications_active_rounded,
        'color': [Colors.orange.shade600, Colors.orange.shade400],
        'action':
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationsScreen(),
              ),
            ),
      },
      {
        'title': 'Profile',
        'icon': Icons.business_rounded,
        'color': [Colors.purple.shade600, Colors.purple.shade400],
        'action': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BusinessProfileScreen(),
            ),
          );
        },
      },
      {
        'title': 'About & Help',
        'icon': Icons.help_outline_rounded,
        'color': [Colors.red.shade500, Colors.red.shade300],
        'action': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AboutHelpScreen()),
          );
        },
      },
    ];

    final feature = features[index];

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: feature['action'] as void Function()?,
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: feature['color'] as List<Color>,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Icon(
                  feature['icon'] as IconData,
                  size: 100,
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      feature['icon'] as IconData,
                      size: 28,
                      color: Colors.white,
                    ),
                    const Spacer(),
                    Text(
                      feature['title'] as String,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 4,
                            color: Colors.black26,
                            offset: Offset(2, 2),
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
}
