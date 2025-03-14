import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:setupfirebase/config.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'auth_provider.dart';
import 'update_profile.dart';

class BusinessProfileScreen extends StatefulWidget {
  const BusinessProfileScreen({Key? key}) : super(key: key);

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _businessData;
  String? _errorMessage;
  bool _hasInternetConnection = true;

  @override
  void initState() {
    super.initState();
    _checkInternetAndFetchData();
  }

  Future<bool> _checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> _checkInternetAndFetchData() async {
    bool hasInternet = await _checkInternetConnection();

    setState(() {
      _hasInternetConnection = hasInternet;
    });

    if (hasInternet) {
      _fetchBusinessProfile();
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage =
            'No internet connection. Please check your connection and try again.';
      });
    }
  }

  Future<void> _fetchBusinessProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get the user ID from auth provider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final uid = authProvider.authData?['user']['uid'];

      if (uid == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'User ID not found. Please log in again.';
        });
        return;
      }

      // Replace with your actual API base URL
      final baseUrl = APIConfig.baseUrl;
      final response = await http
          .get(
            Uri.parse('$baseUrl/profile/business?uid=$uid'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception('Connection timeout. Please try again.');
            },
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _businessData = data['data'];
          _isLoading = false;
        });
      } else {
        final error = json.decode(response.body);
        setState(() {
          _isLoading = false;
          _errorMessage = error['error'] ?? 'Failed to load profile data';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            e.toString().contains('SocketException') ||
                    e.toString().contains('Connection timeout')
                ? 'No internet connection. Please check your connection and try again.'
                : 'Network error: ${e.toString()}';
        _hasInternetConnection =
            !e.toString().contains('SocketException') &&
            !e.toString().contains('Connection timeout');
      });
    }
  }

  String _formatDate(dynamic timestamp) {
    try {
      if (timestamp == null) return 'N/A';

      // Handle Firebase timestamp
      if (timestamp is Map && timestamp.containsKey('_seconds')) {
        final seconds = timestamp['_seconds'];
        final dateTime = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
        return DateFormat('MMMM d, yyyy').format(dateTime);
      }

      // Handle string timestamp
      if (timestamp is String) {
        return timestamp;
      }

      return 'N/A';
    } catch (e) {
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Profile'),
        backgroundColor: Colors.indigo,
        elevation: 0,
        actions: [
          if (!_isLoading && _businessData != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                if (!_hasInternetConnection) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'No internet connection. Cannot edit profile.',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => UpdateBusinessProfileScreen(
                          initialData: _businessData,
                        ),
                  ),
                );

                if (result == true) {
                  _checkInternetAndFetchData(); // Refresh data after successful update
                }
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkInternetAndFetchData,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? _buildErrorView()
              : _buildProfileContent(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _hasInternetConnection
                ? Icons.error_outline
                : Icons.signal_wifi_off,
            size: 70,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _checkInternetAndFetchData,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeaderSection(),
          _buildDetailsCard(),
          _buildAddressCard(),
          _buildFinancialCard(),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.indigo,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Text(
              _businessData?['businessName']?.substring(0, 1) ?? 'B',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _businessData?['businessName'] ?? 'Business Name',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Established: ${_formatDate(_businessData?['createdAt'])}',
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Business Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const Divider(height: 24),
            _buildDetailRow(
              icon: Icons.person,
              title: 'Owner',
              value: _businessData?['ownerName'] ?? 'N/A',
            ),
            _buildDetailRow(
              icon: Icons.phone,
              title: 'Contact',
              value: _businessData?['phone'] ?? 'N/A',
            ),
            _buildDetailRow(
              icon: Icons.description,
              title: 'Description',
              value:
                  _businessData?['description'] ?? 'No description available',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Location',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const Divider(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, color: Colors.indigo),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _businessData?['address'] ?? 'Address not available',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Financial Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const Divider(height: 24),
            _buildDetailRow(
              icon: Icons.currency_rupee,
              title: 'Monthly fees',
              value: '₹${_businessData?['rent']?.toString() ?? 'N/A'}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.indigo),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
