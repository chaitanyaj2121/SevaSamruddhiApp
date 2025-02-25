import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> customers = [];
  bool _isLoading = true;
  bool _isError = false; // Added error state

  @override
  void initState() {
    super.initState();
    _fetchCustomerData();
  }

  Future<void> _fetchCustomerData() async {
    setState(() {
      _isLoading = true;
      _isError = false;
    });

    try {
      final response = await http.get(
        Uri.parse("http://192.168.166.11:8080/dashboard"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> fetchedCustomers = data['customers'] ?? [];

        // Format start_date
        for (var customer in fetchedCustomers) {
          if (customer['start_date']?['_seconds'] != null) {
            int timestamp = customer['start_date']['_seconds'] * 1000;
            customer['formattedStartDate'] = DateFormat(
              'dd MMM yyyy',
            ).format(DateTime.fromMillisecondsSinceEpoch(timestamp));
          } else {
            customer['formattedStartDate'] = "N/A";
          }
        }

        setState(() {
          customers = fetchedCustomers;
        });
      } else {
        setState(() => _isError = true);
      }
    } catch (e) {
      setState(() => _isError = true);
    } finally {
      setState(() => _isLoading = false);
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
        elevation: 5,
        shadowColor: Colors.black54,
        centerTitle: true,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _isError
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 80, color: Colors.red),
                    const SizedBox(height: 10),
                    const Text(
                      "Failed to fetch data. Please try again.",
                      style: TextStyle(fontSize: 18, color: Colors.red),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _fetchCustomerData,
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              )
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
                          padding: const EdgeInsets.all(16),
                          itemCount: customers.length,
                          itemBuilder: (context, index) {
                            final customer = customers[index];
                            return CustomerCard(customer: customer);
                          },
                        ),
              ),
    );
  }
}

// Extracted CustomerCard for better readability
class CustomerCard extends StatelessWidget {
  final Map<String, dynamic> customer;

  const CustomerCard({Key? key, required this.customer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundImage:
                    customer['customerImage']?['url'] != null
                        ? NetworkImage(customer['customerImage']['url'])
                        : null,
                backgroundColor: Colors.grey[300],
                radius: 30,
                child:
                    customer['customerImage']?['url'] == null
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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    _infoRow(
                      Icons.phone,
                      customer['mobile'] ?? 'N/A',
                      Colors.grey[700],
                    ),
                    const SizedBox(height: 8),
                    _infoRow(
                      Icons.attach_money,
                      "Fees Remain: ₹${2300 - (customer['feesPaid'] ?? 0)}",
                      Colors.green,
                    ),
                    const SizedBox(height: 8),
                    _infoRow(
                      Icons.calendar_today,
                      "S Date: ${customer['formattedStartDate']}",
                      Colors.blueGrey[700],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Mess ID: ${customer['messId'] ?? 'N/A'}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                        ),
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

  Widget _infoRow(IconData icon, String text, Color? color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: color),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
