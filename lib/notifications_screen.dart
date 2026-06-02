import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:setupfirebase/config.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    // Retrieve the messId from AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final messId = authProvider.authData?['user']['uid'];

    // Build the URL with the messId query parameter
    final url = Uri.parse(
      APIConfig.notificationsUrl,
    ).replace(queryParameters: {'messId': messId.toString()});

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data.containsKey('notifications')) {
          setState(() {
            notifications = data['notifications'];
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
        }
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Error fetching notifications: $e");
    }
  }

  Future<void> _renewCustomer(dynamic notification) async {
    // Show a loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Retrieve messId from AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final messId = authProvider.authData?['user']['uid'];

    final url = Uri.parse(APIConfig.renewCustUrl);
    final bodyData = {
      'customerId': notification['id'],
      'messId': messId.toString(),
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(bodyData),
      );
      Navigator.pop(context); // Remove loading dialog
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Renew Success!")));
        // Refresh the notifications list after renew, if needed.
        fetchNotifications();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to renew customer")),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Remove loading dialog
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error renewing customer: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body:
          isLoading
              ? _buildLoadingIndicator()
              : notifications.isEmpty
              ? _buildEmptyState()
              : _buildNotificationList(),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
          ),
          const SizedBox(height: 20),
          Text(
            "Fetching Notifications...",
            style: TextStyle(
              color: AppTheme.mutedText,
              fontSize: 16,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 100,
            color: AppTheme.mutedText,
          ),
          const SizedBox(height: 20),
          Text(
            "No Notifications Today!",
            style: TextStyle(
              color: AppTheme.mutedText,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "All caught up with your renewals",
            style: const TextStyle(color: AppTheme.mutedText, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: notifications.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _NotificationCard(
          notification: notification,
          onRenew: () => _renewCustomer(notification),
        );
      },
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final dynamic notification;
  final VoidCallback onRenew;

  const _NotificationCard({required this.notification, required this.onRenew});

  @override
  Widget build(BuildContext context) {
    final formattedDate = _formatDate(notification);
    final feesPaid = _calculateFeesPaid(notification);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCustomerAvatar(),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification['name'] ?? 'No Name',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.phone, notification['mobile'] ?? 'N/A'),
                  _buildInfoRow(Icons.calendar_today, formattedDate),
                  const SizedBox(height: 8),
                  _buildFeeIndicator(feesPaid),
                ],
              ),
            ),
            _buildRenewButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerAvatar() {
    return CircleAvatar(
      radius: 26,
      backgroundImage:
          notification['customerImage']?['url'] != null
              ? NetworkImage(notification['customerImage']['url'])
              : null,
      backgroundColor: AppTheme.primary.withOpacity(0.12),
      child:
          notification['customerImage']?['url'] == null
              ? const Icon(Icons.person, color: AppTheme.primary, size: 26)
              : null,
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.mutedText),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 13, color: AppTheme.mutedText),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeIndicator(int paid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            _buildInfoChip(
              Icons.payments_outlined,
              "Paid: ₹${NumberFormat().format(paid)}",
              AppTheme.primary,
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: paid / 2300,
          backgroundColor: AppTheme.border,
          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRenewButton(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          icon: const Icon(Icons.autorenew, size: 20),
          onPressed: onRenew,
          tooltip: 'Renew Subscription',
        ),
        const SizedBox(height: 4),
        const Text(
          'Renew',
          style: TextStyle(
            color: AppTheme.primary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatDate(dynamic notification) {
    if (notification['start_date']?['_seconds'] != null) {
      final date = DateTime.fromMillisecondsSinceEpoch(
        notification['start_date']['_seconds'] * 1000,
      );
      return DateFormat('MMM dd, yyyy').format(date);
    }
    return 'Date not available';
  }

  int _calculateFeesPaid(dynamic notification) {
    try {
      return int.parse(notification['feesPaid'].toString());
    } catch (e) {
      return 0;
    }
  }
}
