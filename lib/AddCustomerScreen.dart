import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AddCustomerScreen extends StatefulWidget {
  @override
  _AddCustomerScreenState createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _feesController = TextEditingController();
  final TextEditingController _messIdController =
      TextEditingController(); // ✅ Added messId field
  DateTime? _selectedDate;
  File? _imageFile;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
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
      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('http://192.168.48.11:8080/addCustomer'),
        );

        request.fields['name'] = _nameController.text;
        request.fields['mobile'] = _mobileController.text;
        request.fields['feesPaid'] = _feesController.text;
        request.fields['messId'] = _messIdController.text; // ✅ Added messId
        request.fields['start_date'] =
            _selectedDate != null
                ? _selectedDate!.toIso8601String()
                : DateTime.now().toIso8601String();

        if (_imageFile != null && await _imageFile!.exists()) {
          print('Adding file to request: ${_imageFile!.path}');
          request.files.add(
            await http.MultipartFile.fromPath(
              'file', // ✅ Make sure this matches the backend field name
              _imageFile!.path,
            ),
          );
        } else {
          print('No file selected');
        }

        var response = await request.send();
        var responseBody = await response.stream.bytesToString();
        print('Response Body: $responseBody');

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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          width: 350,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Add New Customer",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Customer Name'),
                  validator:
                      (value) => value!.isEmpty ? 'Enter customer name' : null,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text("Choose File"),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _imageFile == null ? "No file chosen" : "File selected",
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _mobileController,
                  decoration: const InputDecoration(labelText: 'Mobile'),
                  keyboardType: TextInputType.phone,
                  validator:
                      (value) => value!.isEmpty ? 'Enter mobile number' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _messIdController,
                  decoration: const InputDecoration(
                    labelText: 'Mess ID',
                  ), // ✅ Added messId input field
                  validator: (value) => value!.isEmpty ? 'Enter mess ID' : null,
                ),
                const SizedBox(height: 10),
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
                              ? 'mm/dd/yyyy'
                              : "${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}",
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
                TextFormField(
                  controller: _feesController,
                  decoration: const InputDecoration(labelText: 'Fees Paid'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Enter amount' : null,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: _submitForm,
                    child: const Text(
                      'Add Customer',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
