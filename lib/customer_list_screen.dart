import 'package:flutter/material.dart';

class CustomerListScreen extends StatelessWidget {
  final List<dynamic> customers;

  const CustomerListScreen({Key? key, required this.customers})
    : super(key: key);

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
          customers.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    Icon(Icons.people_outline, size: 80, color: Colors.grey),
                    const SizedBox(height: 10),
                    const Text(
                      "No customers found",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              )
              : ListView.builder(
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
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () {
                        // Add navigation or action when a customer is tapped
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Customer Avatar
                            CircleAvatar(
                              backgroundImage:
                                  customer['customerImage']?['url'] != null
                                      ? NetworkImage(
                                        customer['customerImage']['url'],
                                      )
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
                            // Customer Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Customer Name
                                  Text(
                                    customer['name'] ?? 'Unknown',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  // Mobile Number
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
                                  // Fees Paid
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.attach_money,
                                        size: 16,
                                        color: Colors.green,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Fees Paid: ₹${customer['feesPaid'] ?? 0}",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Mess ID
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
                },
              ),
    );
  }
}
