import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';

class CustomerListScreen extends StatefulWidget {
  final List<dynamic> customers;

  const CustomerListScreen({Key? key, required this.customers})
    : super(key: key);

  @override
  _CustomerListScreenState createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  TextEditingController searchController = TextEditingController();
  List<dynamic> filteredCustomers = [];
  bool isLoading = true; // Add loading state

  @override
  void initState() {
    super.initState();
    // Simulate loading delay to show loading state
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        filteredCustomers = widget.customers;
        isLoading = false;
      });
    });
  }

  void _filterCustomers(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredCustomers = widget.customers;
      } else {
        filteredCustomers =
            widget.customers
                .where(
                  (customer) =>
                      customer['name'] != null &&
                      customer['name'].toLowerCase().contains(
                        query.toLowerCase(),
                      ),
                )
                .toList();
      }
    });
  }

  void _showUpdateCustomerBottomSheet(BuildContext context, dynamic customer) {
    TextEditingController nameController = TextEditingController(
      text: customer['name'] ?? '',
    );
    TextEditingController mobileController = TextEditingController(
      text: customer['mobile'] ?? '',
    );
    TextEditingController startDateController = TextEditingController(
      text: formatStartDate(customer['start_date']),
    );
    TextEditingController feesPaidController = TextEditingController(
      text: customer['feesPaid']?.toString() ?? '',
    );
    TextEditingController suttyController = TextEditingController(text: "0");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        bool isUpdating = false;
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                  children: [
                    Text(
                      "Manage Customer: ${customer['name']}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildReadOnlyField("Name", nameController),
                    _buildReadOnlyField("Mobile", mobileController),
                    _buildReadOnlyField("Start Date", startDateController),
                    _buildEditableField("Fees Paid", feesPaidController),
                    _buildEditableField("Sutty", suttyController),
                    const SizedBox(height: 20),
                    _buildUpdateButton(isUpdating, () async {
                      setModalState(() => isUpdating = true);
                      final updatedData = {
                        'feesPaid': feesPaidController.text,
                        'suttya': suttyController.text,
                      };

                      try {
                        final response = await http.post(
                          Uri.parse(
                            "${APIConfig.baseUrl}/customers/update/${customer['id']}",
                          ),
                          headers: {"Content-Type": "application/json"},
                          body: jsonEncode(updatedData),
                        );
                        if (response.statusCode == 200) {
                          setState(() {
                            // Updating local list to reflect changes
                            customer['feesPaid'] = feesPaidController.text;
                            customer['suttya'] = suttyController.text;
                          });
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        print("Error updating customer: $e");
                      }
                      setModalState(() => isUpdating = false);
                    }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReadOnlyField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        TextField(
          controller: controller,
          readOnly: true,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildUpdateButton(bool isUpdating, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      ),
      onPressed: isUpdating ? null : onPressed,
      child:
          isUpdating
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("Update", style: TextStyle(color: Colors.white)),
    );
  }

  String formatStartDate(dynamic timestamp) {
    if (timestamp != null && timestamp['_seconds'] != null) {
      DateTime date = DateTime.fromMillisecondsSinceEpoch(
        timestamp['_seconds'] * 1000,
      );
      return DateFormat('dd MMM yyyy').format(date);
    }
    return 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Customers List',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 6,
      ),
      body:
          isLoading
              ? _buildLoadingState() // Display loading state
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      controller: searchController,
                      onChanged: _filterCustomers,
                      decoration: InputDecoration(
                        hintText: 'Search by name...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child:
                        filteredCustomers.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                              itemCount: filteredCustomers.length,
                              itemBuilder: (context, index) {
                                final customer = filteredCustomers[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(15),
                                    onTap: () {},
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildCustomerAvatar(customer),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                _buildCustomerName(customer),
                                                _buildCustomerPhone(customer),
                                                _buildFeesPaid(customer),
                                                _buildStartDate(customer),
                                                // Removed MessID display as requested
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.deepPurple,
                                              size: 28,
                                            ),
                                            onPressed: () {
                                              _showUpdateCustomerBottomSheet(
                                                context,
                                                customer,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
    );
  }

  // New method to display loading state
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(color: Colors.deepPurple, strokeWidth: 5),
          SizedBox(height: 20),
          Text(
            "Loading customers...",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
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
        children: const [
          Icon(Icons.people_outline, size: 80, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "No customers found",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerAvatar(dynamic customer) {
    return CircleAvatar(
      backgroundImage:
          customer['customerImage']?['url'] != null
              ? NetworkImage(customer['customerImage']['url'])
              : null,
      backgroundColor:
          customer['customerImage']?['url'] == null
              ? Colors.purple[100]
              : Colors.transparent,
      radius: 30,
      child:
          customer['customerImage']?['url'] == null
              ? const Icon(Icons.person, color: Colors.deepPurple, size: 30)
              : null,
    );
  }

  Widget _buildCustomerName(dynamic customer) {
    return Text(
      customer['name'] ?? 'Unknown',
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildCustomerPhone(dynamic customer) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.phone, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            customer['mobile'] ?? 'N/A',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildFeesPaid(dynamic customer) {
    return Row(
      children: [
        const Icon(Icons.attach_money, size: 16, color: Colors.green),
        const SizedBox(width: 8),
        Text(
          "Paid: ₹${customer['feesPaid'] ?? 0}",
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildStartDate(dynamic customer) {
    return Row(
      children: [
        const Icon(Icons.calendar_today, size: 16, color: Colors.blue),
        const SizedBox(width: 8),
        Text(
          "Date: ${formatStartDate(customer['start_date'])}",
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // Removed _buildMessId method as it's no longer needed
}
