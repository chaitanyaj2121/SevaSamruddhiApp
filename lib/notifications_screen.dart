import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:setupfirebase/config.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';

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
    final url = Uri.parse(APIConfig.renewCustUrl);
    final bodyData = {
      'customerId': notification['id'],
    }; // Ensure 'id' exists in your notification object
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
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(blurRadius: 2, offset: Offset(1, 1))],
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepOrange, Colors.orangeAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
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
            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
          ),
          const SizedBox(height: 20),
          Text(
            "Fetching Notifications...",
            style: TextStyle(
              color: Colors.grey[600],
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
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            "No Notifications Today!",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "All caught up with your renewals",
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
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
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.orangeAccent, width: 2),
      ),
      child: ClipOval(
        child:
            notification['customerImage']?['url'] != null
                ? Image.network(
                  notification['customerImage']['url'],
                  fit: BoxFit.cover,
                  loadingBuilder:
                      (context, child, loadingProgress) =>
                          loadingProgress == null
                              ? child
                              : const Center(
                                child: CircularProgressIndicator(),
                              ),
                  errorBuilder:
                      (context, error, stackTrace) =>
                          const Icon(Icons.person_outline),
                )
                : const Icon(Icons.person_outline, size: 30),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
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
            _buildFeeChip(
              "Paid: ₹${NumberFormat().format(paid)}",
              Colors.green,
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: paid / 2300,
          backgroundColor: Colors.grey[200],
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildFeeChip(String text, Color color) {
    return Chip(
      // Changed vertical padding from -4 to 2 to avoid text overlap
      labelPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      label: Text(
        text,
        style: const TextStyle(fontSize: 10, color: Colors.white),
      ),
      backgroundColor: color.withOpacity(0.8),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.zero,
    );
  }

  Widget _buildRenewButton(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.autorenew, size: 20),
          color: Colors.deepOrange,
          onPressed: onRenew,
          padding: const EdgeInsets.all(6),
          constraints: const BoxConstraints(),
          tooltip: 'Renew Subscription',
          style: IconButton.styleFrom(
            backgroundColor: Colors.deepOrange.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const Text(
          'Renew',
          style: TextStyle(
            color: Colors.deepOrange,
            fontSize: 10,
            fontWeight: FontWeight.w500,
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
