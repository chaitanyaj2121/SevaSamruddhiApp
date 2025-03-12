import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'config.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> customers = [];
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();
  List<dynamic> filteredCustomers = [];
  int? userFees;
  String? messId; // Store messId for reuse

  void _filterCustomers(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredCustomers = List.from(customers); // Reset list when empty
      } else {
        filteredCustomers =
            customers.where((customer) {
              final name = customer['name']?.toLowerCase() ?? '';
              return name.contains(query.toLowerCase());
            }).toList();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchCustomerData();
  }

  Future<void> _fetchCustomerData() async {
    try {
      // Retrieve messId and fees from your AuthProvider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final uid = authProvider.authData?['user']['uid'];
      final fees = authProvider.authData?['user']['fees'];

      setState(() {
        userFees = fees;
        messId = uid; // Store messId for reuse in other API calls
      });

      // Build the URI with both messId and fees as query parameters
      final uri = Uri.parse(APIConfig.dashboardUrl).replace(
        queryParameters: {'messId': messId.toString(), 'fees': fees.toString()},
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          customers = data['customers'] ?? [];
          filteredCustomers = List.from(customers);
        });
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
        _showUpdateCustomerBottomSheet(customer);
        break;
      case 'renew':
        _renewCustomer(customer);
        break;
      case 'delete':
        _deleteCustomer(customer);
        break;
    }
  }

  Future<void> _deleteCustomer(dynamic customer) async {
    // Show a loading indicator while the delete request is processing
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(child: CircularProgressIndicator());
      },
    );

    final url = Uri.parse(APIConfig.deleteCustUrl);
    final bodyData = {
      'customerId': customer['id'],
      'messId': messId, // Add messId to request body
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(bodyData),
      );

      Navigator.pop(context); // Dismiss the loading indicator

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Customer deleted successfully!")),
        );
        _fetchCustomerData(); // Refresh the customer list
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to delete customer")));
      }
    } catch (error) {
      Navigator.pop(context); // Dismiss the loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting customer: $error")),
      );
    }
  }

  Future<void> _renewCustomer(dynamic customer) async {
    // Show a loading indicator (using a dialog)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(child: CircularProgressIndicator());
      },
    );

    final url = Uri.parse(APIConfig.renewCustUrl);
    final bodyData = {
      'customerId': customer['id'],
      'messId': messId, // Add messId to request body
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(bodyData),
      );

      Navigator.pop(context); // Dismiss the loading indicator

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Renew Success!")));
        _fetchCustomerData(); // Refresh the list
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to renew customer")));
      }
    } catch (error) {
      Navigator.pop(context); // Dismiss the loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error renewing customer: $error")),
      );
    }
  }

  // This function creates the modal bottom sheet with the update form.
  void _showUpdateCustomerBottomSheet(dynamic customer) {
    // Controllers for read-only fields
    TextEditingController nameController = TextEditingController(
      text: customer['name'] ?? '',
    );
    TextEditingController mobileController = TextEditingController(
      text: customer['mobile'] ?? '',
    );
    String startDateFormatted = formatTimestamp(customer['start_date']);
    TextEditingController startDateController = TextEditingController(
      text: startDateFormatted,
    );

    // Controllers for editable fields
    TextEditingController feesPaidController = TextEditingController(
      text: customer['feesPaid'] != null ? customer['feesPaid'].toString() : '',
    );
    // Sutty is not in the database, initialize it to "0"
    TextEditingController suttyController = TextEditingController(text: "0");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Adjusts for the keyboard
      builder: (BuildContext context) {
        // Use StatefulBuilder to manage local state for the loading indicator.
        bool isUpdating = false;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Manage Customer: ${customer['name']}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Name (read-only)
                    const Text("Name"),
                    TextField(
                      controller: nameController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Mobile (read-only)
                    const Text("Mobile"),
                    TextField(
                      controller: mobileController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Start Date (read-only)
                    const Text("Start Date"),
                    TextField(
                      controller: startDateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Fees Paid (editable)
                    const Text("Fees Paid"),
                    TextField(
                      controller: feesPaidController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Sutty (editable, default is 0)
                    const Text("Sutty"),
                    TextField(
                      controller: suttyController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        child:
                            isUpdating
                                ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Text("Update"),
                        onPressed:
                            isUpdating
                                ? null
                                : () async {
                                  setModalState(() {
                                    isUpdating = true;
                                  });

                                  // Create the proper update URL with messId as query parameter
                                  final url = Uri.parse(
                                    "${APIConfig.baseUrl}/customers/update/${customer['id']}",
                                  ).replace(
                                    queryParameters: {'messId': messId},
                                  );

                                  // Prepare the updated data payload
                                  final updatedData = {
                                    'feesPaid': feesPaidController.text,
                                    'suttya': suttyController.text,
                                  };

                                  try {
                                    final response = await http.post(
                                      url,
                                      headers: {
                                        "Content-Type": "application/json",
                                      },
                                      body: jsonEncode(updatedData),
                                    );

                                    if (response.statusCode == 200) {
                                      // Success message
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Customer updated successfully!",
                                          ),
                                        ),
                                      );

                                      // Refresh the customer list
                                      _fetchCustomerData();
                                      Navigator.pop(
                                        context,
                                      ); // Dismiss the bottom sheet
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Failed to update customer",
                                          ),
                                        ),
                                      );
                                      print(
                                        "Failed to update customer: ${response.body}",
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Error updating customer: $e",
                                        ),
                                      ),
                                    );
                                    print("Error updating customer: $e");
                                  }

                                  setModalState(() {
                                    isUpdating = false;
                                  });
                                },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
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
                child: Column(
                  children: [
                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Search by Name',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged:
                            _filterCustomers, // Calls the function on typing
                      ),
                    ),

                    // Customers List
                    Expanded(
                      child:
                          filteredCustomers.isEmpty
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
                                itemCount: filteredCustomers.length,
                                itemBuilder: (context, index) {
                                  final customer = filteredCustomers[index];
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                backgroundColor:
                                                    Colors.grey[300],
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
                                                      customer['name'] ??
                                                          'Unknown',
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      "Fees Paid: ₹${customer['feesPaid'] ?? 0}",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      "Fees Remaining: ₹${(userFees ?? 0) - (customer['feesPaid'] ?? 0)}",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
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
                                              PopupMenuButton<String>(
                                                onSelected:
                                                    (value) =>
                                                        _onMenuItemSelected(
                                                          value,
                                                          customer,
                                                        ),
                                                itemBuilder:
                                                    (context) => [
                                                      PopupMenuItem(
                                                        value: 'manage',
                                                        child: Text('Manage'),
                                                      ),
                                                      PopupMenuItem(
                                                        value: 'renew',
                                                        child: Text('Renew'),
                                                      ),
                                                      PopupMenuItem(
                                                        value: 'delete',
                                                        child: Text('Delete'),
                                                      ),
                                                    ],
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
                  ],
                ),
              ),
    );
  }
}
