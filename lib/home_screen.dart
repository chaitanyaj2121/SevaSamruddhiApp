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
import 'subscription_provider.dart';
import 'subscription_screen.dart';

class HomeScreen extends StatefulWidget {
  final String uid;

  const HomeScreen({super.key, required this.uid});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeSubscription();
  }

  Future<void> _initializeSubscription() async {
    // Initialize subscription status
    final subscriptionProvider = Provider.of<SubscriptionProvider>(
      context,
      listen: false,
    );
    await subscriptionProvider.initialize(widget.uid);
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.purple.shade600),
        ),
      );
    }

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
            Row(
              children: [
                _buildSubscriptionIndicator(),
                const SizedBox(width: 10),
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
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionIndicator() {
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context);

    if (subscriptionProvider.hasActiveSubscription) {
      final endDate = subscriptionProvider.currentSubscription!.endDate;
      final remainingDays = endDate.difference(DateTime.now()).inDays;

      return InkWell(
        onTap: () {
          _showSubscriptionDetails(context);
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(
                '$remainingDays days left',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    const SubscriptionScreen(featureTitle: 'Premium Features'),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          children: [
            Icon(Icons.card_membership, color: Colors.white, size: 18),
            SizedBox(width: 6),
            Text(
              'Subscribe',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSubscriptionDetails(BuildContext context) {
    final subscriptionProvider = Provider.of<SubscriptionProvider>(
      context,
      listen: false,
    );
    final subscription = subscriptionProvider.currentSubscription!;

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Your Subscription'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Duration: ${subscription.durationMonths} month(s)'),
                const SizedBox(height: 8),
                Text('Start Date: ${_formatDate(subscription.startDate)}'),
                const SizedBox(height: 8),
                Text('End Date: ${_formatDate(subscription.endDate)}'),
                const SizedBox(height: 8),
                Text('Amount Paid: ₹${subscription.amount}'),
                const SizedBox(height: 8),
                Text('Status: ${subscription.status.toUpperCase()}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
        'isPremium': false,
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
        'isPremium': true,
        'action': () {
          final subscriptionProvider = Provider.of<SubscriptionProvider>(
            context,
            listen: false,
          );

          if (subscriptionProvider.hasActiveSubscription) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DashboardScreen()),
            );
          } else {
            _showPremiumFeatureDialog(context, 'Dashboard');
          }
        },
      },
      {
        'title': 'Notifications',
        'icon': Icons.notifications_active_rounded,
        'color': [Colors.orange.shade600, Colors.orange.shade400],
        'isPremium': false,
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
        'isPremium': false,
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
        'isPremium': false,
        'action': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AboutHelpScreen()),
          );
        },
      },
    ];

    final feature = features[index];
    final subscriptionProvider = Provider.of<SubscriptionProvider>(
      context,
      listen: false,
    );

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
              if (feature['isPremium'] as bool)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        const Text(
                          'PREMIUM',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
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

  void _showPremiumFeatureDialog(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.star, color: Colors.amber),
                SizedBox(width: 8),
                Text('Premium Feature'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'The $featureName feature is only available with a premium subscription.',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                Text(
                  'Upgrade now to access all premium features!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: Text('Later'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => const SubscriptionScreen(
                            featureTitle: 'Premium Features',
                          ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
                child: Text('Subscribe Now'),
              ),
            ],
          ),
    );
  }
}
