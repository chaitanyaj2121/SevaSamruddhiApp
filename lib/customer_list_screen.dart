import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'app_theme.dart';
import 'config.dart';

class CustomerListScreen extends StatefulWidget {
  final String? messId;

  const CustomerListScreen({Key? key, required this.messId}) : super(key: key);

  @override
  _CustomerListScreenState createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final TextEditingController searchController = TextEditingController();
  List<dynamic> customers = [];
  List<dynamic> filteredCustomers = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchCustomers();
  }

  Future<bool> _checkInternetConnectivity() async {
    try {
      final response = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<void> fetchCustomers() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final isConnected = await _checkInternetConnectivity();
      if (!isConnected) {
        setState(() {
          errorMessage =
              'No internet connection. Please check your network settings and try again.';
          isLoading = false;
        });
        return;
      }

      final uri = Uri.parse(
        APIConfig.customersUrl,
      ).replace(queryParameters: {'messId': widget.messId});

      final response = await http
          .get(uri)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Connection timeout. Please try again.');
            },
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true && data.containsKey('customers')) {
          setState(() {
            customers = data['customers'];
            filteredCustomers = customers;
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'Invalid response format';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage =
              'Failed to load customers. Status: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  void _filterCustomers(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredCustomers = customers;
      } else {
        filteredCustomers =
            customers.where((customer) {
              final name = customer['name']?.toString().toLowerCase() ?? '';
              return name.contains(query.toLowerCase());
            }).toList();
      }
    });
  }

  void _showUpdateCustomerBottomSheet(BuildContext context, dynamic customer) {
    final nameController = TextEditingController(text: customer['name'] ?? '');
    final mobileController = TextEditingController(
      text: customer['mobile'] ?? '',
    );
    final startDateController = TextEditingController(
      text: formatStartDate(customer['start_date']),
    );
    final feesPaidController = TextEditingController(
      text: customer['feesPaid']?.toString() ?? '',
    );
    final suttyController = TextEditingController(text: '0');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        bool isUpdating = false;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        height: 4,
                        width: 44,
                        margin: const EdgeInsets.only(bottom: 18),
                        decoration: BoxDecoration(
                          color: AppTheme.border,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    Text(
                      "Manage ${customer['name'] ?? 'Customer'}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildReadOnlyField('Name', nameController),
                    _buildReadOnlyField('Mobile', mobileController),
                    _buildReadOnlyField('Start Date', startDateController),
                    _buildEditableField('Fees Paid', feesPaidController),
                    _buildEditableField('Sutty', suttyController),
                    const SizedBox(height: 8),
                    _buildUpdateButton(isUpdating, () async {
                      setModalState(() => isUpdating = true);

                      final isConnected = await _checkInternetConnectivity();
                      if (!isConnected) {
                        setModalState(() => isUpdating = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'No internet connection. Please check your network and try again.',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final updatedData = {
                        'feesPaid': feesPaidController.text,
                        'suttya': suttyController.text,
                      };

                      try {
                        final updateUri = Uri.parse(
                          '${APIConfig.baseUrl}/customers/update/${customer['id']}',
                        ).replace(queryParameters: {'messId': widget.messId});

                        final response = await http
                            .post(
                              updateUri,
                              headers: {'Content-Type': 'application/json'},
                              body: jsonEncode(updatedData),
                            )
                            .timeout(const Duration(seconds: 10));

                        if (response.statusCode == 200) {
                          await fetchCustomers();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Customer updated successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          final errorData = jsonDecode(response.body);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                errorData['message'] ?? 'Update failed',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
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
    return _buildSheetField(label, controller, readOnly: true);
  }

  Widget _buildEditableField(String label, TextEditingController controller) {
    return _buildSheetField(
      label,
      controller,
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildSheetField(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            fillColor: readOnly ? const Color(0xFFF8FAF8) : AppTheme.surface,
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildUpdateButton(bool isUpdating, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: isUpdating ? null : onPressed,
      child:
          isUpdating
              ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
              : const Text('Update Customer'),
    );
  }

  String formatStartDate(dynamic timestamp) {
    if (timestamp != null && timestamp['_seconds'] != null) {
      final date = DateTime.fromMillisecondsSinceEpoch(
        timestamp['_seconds'] * 1000,
      );
      return DateFormat('dd MMM yyyy').format(date);
    }
    return 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: fetchCustomers,
          ),
        ],
      ),
      body:
          isLoading
              ? _buildLoadingState()
              : errorMessage != null
              ? _buildErrorState()
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                    child: TextField(
                      controller: searchController,
                      onChanged: _filterCustomers,
                      decoration: const InputDecoration(
                        hintText: 'Search by name...',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${filteredCustomers.length} customers',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.mutedText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child:
                        filteredCustomers.isEmpty
                            ? _buildEmptyState()
                            : RefreshIndicator(
                              onRefresh: fetchCustomers,
                              child: ListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  0,
                                  20,
                                  24,
                                ),
                                itemCount: filteredCustomers.length,
                                itemBuilder: (context, index) {
                                  final customer = filteredCustomers[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap:
                                          () => _showUpdateCustomerBottomSheet(
                                            context,
                                            customer,
                                          ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _buildCustomerAvatar(customer),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  _buildCustomerName(customer),
                                                  const SizedBox(height: 8),
                                                  _buildCustomerPhone(customer),
                                                  const SizedBox(height: 10),
                                                  Wrap(
                                                    spacing: 8,
                                                    runSpacing: 8,
                                                    children: [
                                                      _buildFeesPaid(customer),
                                                      _buildStartDate(customer),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton.filledTonal(
                                              tooltip: 'Edit customer',
                                              icon: const Icon(Icons.edit),
                                              onPressed:
                                                  () =>
                                                      _showUpdateCustomerBottomSheet(
                                                        context,
                                                        customer,
                                                      ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                  ),
                ],
              ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(strokeWidth: 3),
          SizedBox(height: 18),
          Text(
            'Loading customers...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              errorMessage?.contains('internet') ?? false
                  ? Icons.signal_wifi_off
                  : Icons.error_outline,
              size: 72,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage ?? 'An error occurred',
              style: const TextStyle(fontSize: 15, color: AppTheme.mutedText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: fetchCustomers,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 72, color: AppTheme.mutedText),
          SizedBox(height: 12),
          Text(
            'No customers found',
            style: TextStyle(fontSize: 16, color: AppTheme.mutedText),
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
              ? AppTheme.primary.withOpacity(0.12)
              : Colors.transparent,
      radius: 30,
      child:
          customer['customerImage']?['url'] == null
              ? const Icon(Icons.person, color: AppTheme.primary, size: 30)
              : null,
    );
  }

  Widget _buildCustomerName(dynamic customer) {
    return Text(
      customer['name'] ?? 'Unknown',
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildCustomerPhone(dynamic customer) {
    return Row(
      children: [
        const Icon(Icons.phone, size: 16, color: AppTheme.mutedText),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            customer['mobile'] ?? 'N/A',
            style: const TextStyle(fontSize: 13, color: AppTheme.mutedText),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFeesPaid(dynamic customer) {
    return _buildInfoChip(
      Icons.payments_outlined,
      'Paid: Rs ${customer['feesPaid'] ?? 0}',
      AppTheme.primary,
    );
  }

  Widget _buildStartDate(dynamic customer) {
    return _buildInfoChip(
      Icons.calendar_today,
      formatStartDate(customer['start_date']),
      const Color(0xFF3461A4),
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
}
