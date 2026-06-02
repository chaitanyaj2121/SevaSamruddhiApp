import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AboutHelpScreen extends StatelessWidget {
  const AboutHelpScreen({Key? key}) : super(key: key);

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About SevaSamruddhi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple.shade700, Colors.purple.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFF5F5F5)],
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(),
              const SizedBox(height: 24),
              _buildTargetUserSection(),
              const SizedBox(height: 24),
              _buildFeaturesSection(),
              const SizedBox(height: 24),
              _buildDeveloperSection(context),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade500, Colors.deepPurple.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Manage Your Services Smartly',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Welcome to SevaSamruddhi Center, your ultimate solution for managing monthly services with ease. Track customer subscriptions, update payments, and streamline operations all in one place.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTargetUserSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.people_alt_rounded,
                  color: Colors.deepPurple.shade600,
                  size: 24,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Who Can Use This Application?',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTargetUserItem(
              icon: Icons.restaurant,
              title: 'Mess Owners',
              description:
                  'Easily manage monthly food subscriptions and adjust absentee days.',
            ),
            const SizedBox(height: 12),
            _buildTargetUserItem(
              icon: Icons.home,
              title: 'Room Owners',
              description:
                  'Get notifications when a tenant\'s rent is due at the end of the month.',
            ),
            const SizedBox(height: 12),
            _buildTargetUserItem(
              icon: Icons.miscellaneous_services,
              title: 'Service Providers',
              description: 'Track customer payments and renewals effortlessly.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetUserItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.deepPurple.shade400, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesSection() {
    final features = [
      {
        'icon': Icons.people_alt_rounded,
        'title': 'Comprehensive Customer Management',
        'description':
            'Add, update, and track subscription details, payments, and balances.',
      },
      {
        'icon': Icons.notifications_active,
        'title': 'Timely Notifications',
        'description':
            'Get alerts when subscriptions or rent payments are due.',
      },
      {
        'icon': Icons.calendar_today,
        'title': 'Absentee Day Adjustments',
        'description':
            'Extend subscription days for customers who missed specific days.',
      },
      {
        'icon': Icons.payment,
        'title': 'Real-Time Payment Tracking',
        'description': 'Stay updated with fees paid and remaining balances.',
      },
      {
        'icon': Icons.dashboard,
        'title': 'Dashboard Analytics',
        'description':
            'Gain insights into customer trends, payments, and absenteeism.',
      },
      {
        'icon': Icons.image,
        'title': 'Customer Images',
        'description':
            'Upload and view customer images for quick identification.',
      },
    ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: Colors.deepPurple.shade600, size: 24),
                const SizedBox(width: 10),
                const Text(
                  'Why SevaSamruddhi Center?',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Discover how our platform helps you manage services and customers effortlessly.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: features.length,
              separatorBuilder: (context, index) => const Divider(height: 24),
              itemBuilder: (context, index) {
                return _buildFeatureItem(
                  icon: features[index]['icon'] as IconData,
                  title: features[index]['title'] as String,
                  description: features[index]['description'] as String,
                );
              },
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Simplify Your Management Today',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Join hundreds of businesses using SevaSamruddhi Center to streamline operations and enhance efficiency.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.deepPurple.shade400, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeveloperSection(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.code, color: Colors.deepPurple.shade600, size: 24),
                const SizedBox(width: 10),
                const Text(
                  'Get Help',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDeveloperInfoItem(
              icon: Icon(Icons.person, color: Colors.deepPurple.shade400, size: 20),
              title: 'Developed by',
              info: 'Chaitanya Jawanjal',
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _launchUrl('mailto:chaitanyajawanjal21@gmail.com'),
              child: _buildDeveloperInfoItem(
                icon: Icon(Icons.email, color: Colors.deepPurple.shade400, size: 20),
                title: 'Contact',
                info: 'Chaitanyajawanjal21@gmail.com',
                isLink: true,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap:
                  () => _launchUrl(
                    'https://www.linkedin.com/in/chaitanya-jawanjal-b01785270/',
                  ),
              child: _buildDeveloperInfoItem(
                icon: FaIcon(
                  FontAwesomeIcons.linkedin,
                  color: Colors.deepPurple.shade400,
                  size: 20,
                ),
                title: 'LinkedIn',
                info: 'Chaitanya Jawanjal',
                isLink: true,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap:
                  () => _launchUrl('https://www.instagram.com/chaitanyadjp/'),
              child: _buildDeveloperInfoItem(
                icon: Icon(
                  Icons.photo_camera,
                  color: Colors.deepPurple.shade400,
                  size: 20,
                ),
                title: 'Instagram',
                info: '@chaitanyadjp',
                isLink: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperInfoItem({
    required Widget icon,
    required String title,
    required String info,
    bool isLink = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: icon,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                info,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isLink ? Colors.blue.shade700 : Colors.black87,
                  decoration:
                      isLink ? TextDecoration.underline : TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
