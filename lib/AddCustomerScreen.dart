import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import './widgets/smartserve_header.dart'; // ✅ Imported SmartServe Header
import 'config.dart';

class AddCustomerScreen extends StatefulWidget {
  @override
  _AddCustomerScreenState createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _feesController = TextEditingController();
  final TextEditingController _messIdController = TextEditingController();
  DateTime? _selectedDate;
  File? _imageFile;
  bool isLoading = false; // ✅ Loading state

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true; // ✅ Show loading indicator
      });

      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse(APIConfig.addCustomerUrl),
        );

        request.fields['name'] = _nameController.text;
        request.fields['mobile'] = _mobileController.text;
        request.fields['feesPaid'] =
            double.tryParse(_feesController.text)?.toString() ?? '0.0';

        request.fields['messId'] =
            int.tryParse(_messIdController.text)?.toString() ?? '0';

        request.fields['start_date'] =
            _selectedDate != null
                ? _selectedDate!.toIso8601String()
                : DateTime.now().toIso8601String();

        if (_imageFile != null && await _imageFile!.exists()) {
          // print('Adding file to request: ${_imageFile!.path}');
          request.files.add(
            await http.MultipartFile.fromPath('file', _imageFile!.path),
          );
        } else {
          // print('No file selected');
        }

        var response = await request.send();
        var responseBody = await response.stream.bytesToString();
        // print('Response Body: $responseBody');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Customer added successfully!')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add customer: $responseBody')),
          );
        }
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        setState(() {
          isLoading = false; // ✅ Hide loading indicator after response
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "Add Customer",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Customer Details",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Customer Name',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Enter customer name' : null,
                  ),
                  const SizedBox(height: 10),

                  // Mobile Field
                  TextFormField(
                    controller: _mobileController,
                    decoration: InputDecoration(
                      labelText: 'Mobile Number',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Enter mobile number' : null,
                  ),
                  const SizedBox(height: 10),

                  /// Mess ID Field
                  TextFormField(
                    controller: _messIdController,
                    decoration: InputDecoration(
                      labelText: 'Mess ID',
                      prefixIcon: Icon(Icons.business),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number, // ✅ Allow only numbers
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter mess ID';
                      }
                      if (int.tryParse(value) == null) {
                        // ✅ Ensure it's a valid integer
                        return 'Mess ID must be a number';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 10),

                  // Date Picker
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Starting Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedDate == null
                                ? 'Select date'
                                : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                            style: TextStyle(
                              color:
                                  _selectedDate == null
                                      ? Colors.grey
                                      : Colors.black,
                            ),
                          ),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Fees Paid Field
                  TextFormField(
                    controller: _feesController,
                    decoration: InputDecoration(
                      labelText: 'Fees Paid',
                      prefixIcon: Icon(Icons.money),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number, // ✅ Allow only numbers
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter amount';
                      }
                      if (int.tryParse(value) == null) {
                        // ✅ Ensure it's a valid integer
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 10),

                  // Image Upload
                  Center(
                    child: Column(
                      children: [
                        _imageFile == null
                            ? Text(
                              "No Image Selected",
                              style: TextStyle(color: Colors.grey),
                            )
                            : Image.file(_imageFile!, height: 100),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              icon: Icon(Icons.camera_alt),
                              onPressed: () => _pickImage(ImageSource.camera),
                              label: Text("Capture"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            ElevatedButton.icon(
                              icon: Icon(Icons.photo),
                              onPressed: () => _pickImage(ImageSource.gallery),
                              label: Text("Gallery"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Submit Button with Loading State
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          162,
                          207,
                          243,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed:
                          isLoading
                              ? null
                              : _submitForm, // ✅ Disabled while loading
                      child:
                          isLoading
                              ? CircularProgressIndicator(
                                color: Colors.white,
                              ) // ✅ Show loader
                              : const Text(
                                'Add Customer',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
