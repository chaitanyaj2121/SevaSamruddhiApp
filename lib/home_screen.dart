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
import 'config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  final String uid;

  const HomeScreen({super.key, required this.uid});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoadingStats = true;
  int _totalCustomers = 0;
  int _customersWithRemainingFees = 0;
  double _totalRemainingFees = 0;

  @override
  void initState() {
    super.initState();
    _fetchHomeStats();
  }

  Future<void> _fetchHomeStats() async {
    try {
      final authProvider = Provider.of<AuthProvider>(
        context,
        listen: false,
      );
      final messId = authProvider.authData?['user']['uid'];
      final fees = authProvider.authData?['user']['fees'];

      if (messId == null) {
        setState(() => _isLoadingStats = false);
        return;
      }

      final uri = Uri.parse(APIConfig.dashboardHomeStatsUrl).replace(
        queryParameters: {
          'messId': messId.toString(),
          'fees': fees?.toString() ?? '0',
        },
      );

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final stats = data['stats'] as Map<String, dynamic>?;

        if (stats != null) {
          setState(() {
            _totalCustomers = (stats['totalCustomers'] ?? 0) as int;
            _customersWithRemainingFees =
                (stats['customersWithRemainingFees'] ?? 0) as int;
            _totalRemainingFees =
                (stats['totalRemainingFees'] ?? 0).toDouble();
            _isLoadingStats = false;
          });
          return;
        }
      }
    } catch (_) {
      // Ignore and fall back to zeroes.
    }

    if (mounted) {
      setState(() => _isLoadingStats = false);
    }
  }

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
                const SizedBox(height: 16),
                _buildStatsRow(),
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

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: 'Total customers',
            value: _isLoadingStats ? '--' : '$_totalCustomers',
            icon: Icons.people_alt_outlined,
            color: AppTheme.primary,
            onTap: () {
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
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            label: 'Remaining customers',
            value: _isLoadingStats ? '--' : '$_customersWithRemainingFees',
            icon: Icons.receipt_long_outlined,
            color: const Color(0xFF3461A4),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DashboardScreen()),
                ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            label: 'Total remaining',
            value:
                _isLoadingStats
                    ? '--'
                    : 'Rs ${_totalRemainingFees.toStringAsFixed(0)}',
            icon: Icons.payments_outlined,
            color: const Color(0xFFC46A2B),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DashboardScreen()),
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.mutedText,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
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
