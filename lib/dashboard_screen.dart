import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> customers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCustomerData();
  }

  Future<void> _fetchCustomerData() async {
    try {
      final response = await http.get(
        Uri.parse("http://192.168.166.11:8080/dashboard"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => customers = data['customers'] ?? []);
      }
    } catch (e) {
      print("Error fetching data: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String formatTimestamp(dynamic timestamp) {
    if (timestamp != null && timestamp['_seconds'] != null) {
      DateTime date = DateTime.fromMillisecondsSinceEpoch(
        timestamp['_seconds'] * 1000,
      );
      return DateFormat('dd MMM yy').format(date);
    }
    return 'N/A';
  }

  void _onMenuItemSelected(String value, dynamic customer) {
    switch (value) {
      case 'manage':
        print("Manage customer: ${customer['name']}");
        break;
      case 'renew':
        print("Renew customer: ${customer['name']}");
        break;
      case 'delete':
        print("Delete customer: ${customer['name']}");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Customers List',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _fetchCustomerData,
                child:
                    customers.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 80,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "No customers found",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: customers.length,
                          itemBuilder: (context, index) {
                            final customer = customers[index];

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          backgroundImage:
                                              customer['customerImage']?['url'] !=
                                                      null
                                                  ? NetworkImage(
                                                    customer['customerImage']['url'],
                                                  )
                                                  : null,
                                          backgroundColor: Colors.grey[300],
                                          radius: 30,
                                          child:
                                              customer['customerImage']?['url'] ==
                                                      null
                                                  ? const Icon(
                                                    Icons.person,
                                                    color: Colors.white,
                                                    size: 30,
                                                  )
                                                  : null,
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                customer['name'] ?? 'Unknown',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.phone,
                                                    size: 16,
                                                    color: Colors.grey[700],
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    customer['mobile'] ?? 'N/A',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey[700],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.attach_money,
                                                    size: 16,
                                                    color: Colors.green,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    "Fees Remain: ₹${2300 - (customer['feesPaid'] ?? 0)}",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                "Start Date: ${formatTimestamp(customer['start_date'])}",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.blueGrey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    // Buttons displayed vertically
                                    Column(
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed:
                                              () => _onMenuItemSelected(
                                                'manage',
                                                customer,
                                              ),
                                          icon: Icon(Icons.settings),
                                          label: Text('Manage'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        ElevatedButton.icon(
                                          onPressed:
                                              () => _onMenuItemSelected(
                                                'renew',
                                                customer,
                                              ),
                                          icon: Icon(Icons.refresh),
                                          label: Text('Renew'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        ElevatedButton.icon(
                                          onPressed:
                                              () => _onMenuItemSelected(
                                                'delete',
                                                customer,
                                              ),
                                          icon: Icon(Icons.delete),
                                          label: Text('Delete'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
              ),
    );
  }
}
