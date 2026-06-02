import 'package:flutter/material.dart';
import 'customer_list_screen.dart';
import 'AddCustomerScreen.dart';
import 'dashboard_screen.dart';
import 'profile.dart';
import 'notifications_screen.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'login_screen.dart';
import 'about_help_screen.dart';
import 'app_theme.dart';

class HomeScreen extends StatelessWidget {
  final String uid;

  const HomeScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(context),
      body: _buildBody(context),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      toolbarHeight: 76,
      automaticallyImplyLeading: false,
      titleSpacing: 20,
      title: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.restaurant_menu, color: AppTheme.primary),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('SevaSamruddhi'),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton.filledTonal(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              await authProvider.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildWelcomeHeader(),
                const SizedBox(height: 20),
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 5,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.12,
                  ),
                  itemBuilder: (context, index) {
                    return _buildFeatureCard(context, index);
                  },
                ),
              ]),
            ),
          ),
        ],
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
      icon: const Icon(Icons.person_add_alt_1),
      label: const Text('Add Customer'),
      backgroundColor: AppTheme.primary,
      foregroundColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryDark,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Manage customers, fees, renewals, and business details from one place.',
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Color(0xFFDDEBE7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, int index) {
    final features = [
      {
        'title': 'Customers',
        'subtitle': 'View and update members',
        'icon': Icons.people_alt_rounded,
        'color': const Color(0xFF176B5D),
        'action': () {
          final authProvider = Provider.of<AuthProvider>(
            context,
            listen: false,
          );
          final messId = authProvider.authData?['user']['uid'];

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
        'subtitle': 'Track payments',
        'icon': Icons.analytics_rounded,
        'color': const Color(0xFF3461A4),
        'action':
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DashboardScreen()),
            ),
      },
      {
        'title': 'Notifications',
        'subtitle': 'Recent updates',
        'icon': Icons.notifications_active_rounded,
        'color': const Color(0xFFC46A2B),
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
        'subtitle': 'Business info',
        'icon': Icons.business_rounded,
        'color': const Color(0xFF7251A2),
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
        'title': 'Help',
        'subtitle': 'Support and about',
        'icon': Icons.help_outline_rounded,
        'color': const Color(0xFFB94E48),
        'action': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AboutHelpScreen()),
          );
        },
      },
    ];

    final feature = features[index];
    final color = feature['color'] as Color;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: feature['action'] as void Function()?,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(feature['icon'] as IconData, color: color),
              ),
              const Spacer(),
              Text(
                feature['title'] as String,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                feature['subtitle'] as String,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.mutedText,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
