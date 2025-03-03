// subscription_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'subscription_provider.dart';
import 'razorpay_service.dart';
import 'subscription_model.dart';

class SubscriptionScreen extends StatefulWidget {
  final String featureTitle;

  const SubscriptionScreen({Key? key, required this.featureTitle})
    : super(key: key);

  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int _selectedMonths = 1;
  bool _isProcessing = false;
  late RazorpayService _razorpayService;

  @override
  void initState() {
    super.initState();
    _razorpayService = RazorpayService(
      onSubscriptionSuccess: _handleSubscriptionSuccess,
      onError: _handleError,
    );
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    super.dispose();
  }

  void _handleSubscriptionSuccess(Subscription subscription) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final subscriptionProvider = Provider.of<SubscriptionProvider>(
      context,
      listen: false,
    );

    // Update subscription in provider
    subscriptionProvider
        .updateSubscription(authProvider.authData!['user']['uid'], subscription)
        .then((_) {
          setState(() {
            _isProcessing = false;
          });

          // Show success dialog
          showDialog(
            context: context,
            builder:
                (ctx) => AlertDialog(
                  title: const Text('Subscription Purchased'),
                  content: Text(
                    'Your subscription for ${subscription.durationMonths} month(s) has been activated until ${_formatDate(subscription.endDate)}.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        // Navigate back to home and then to the feature
                        Navigator.of(
                          context,
                        ).pop(true); // Return true to indicate success
                      },
                      child: const Text('Great!'),
                    ),
                  ],
                ),
          );
        });
  }

  void _handleError(String error) {
    setState(() {
      _isProcessing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _startPayment() {
    setState(() {
      _isProcessing = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userData = authProvider.authData!['user'];

    _razorpayService.startPayment(
      uid: userData['uid'],
      name: userData['displayName'] ?? 'User',
      email: userData['email'] ?? '',
      phone: userData['phone'] ?? '',
      durationMonths: _selectedMonths,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subscribe to ${widget.featureTitle}'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple.shade700, Colors.purple.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
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
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Subscribe to Access:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildFeatureItem(Icons.people_alt_rounded, 'Customers'),
                      _buildFeatureItem(Icons.analytics_rounded, 'Dashboard'),
                      _buildFeatureItem(
                        Icons.notifications_active_rounded,
                        'Notifications',
                      ),
                      const SizedBox(height: 10),
                      const Divider(),
                      const SizedBox(height: 10),
                      Text(
                        'Subscription Details:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '• ₹100 per month',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        '• Immediate access to premium features',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        '• No automatic renewal',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Subscription Duration',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Slider(
                        value: _selectedMonths.toDouble(),
                        min: 1,
                        max: 12,
                        divisions: 11,
                        label:
                            '$_selectedMonths month${_selectedMonths > 1 ? 's' : ''}',
                        activeColor: Colors.purple,
                        onChanged: (value) {
                          setState(() {
                            _selectedMonths = value.round();
                          });
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '1',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Text(
                              '12',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.purple.shade200),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Total Amount',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₹${_selectedMonths * 100}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple.shade800,
                              ),
                            ),
                            Text(
                              'for $_selectedMonths month${_selectedMonths > 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _startPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isProcessing
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Proceed to Payment',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.purple, size: 20),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}
