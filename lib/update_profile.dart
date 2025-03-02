import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:setupfirebase/config.dart';
import 'dart:convert';
import 'auth_provider.dart';

class UpdateBusinessProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const UpdateBusinessProfileScreen({Key? key, this.initialData})
    : super(key: key);

  @override
  State<UpdateBusinessProfileScreen> createState() =>
      _UpdateBusinessProfileScreenState();
}

class _UpdateBusinessProfileScreenState
    extends State<UpdateBusinessProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  // Form controllers
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _rentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _businessNameController.text = widget.initialData!['businessName'] ?? '';
      _ownerNameController.text = widget.initialData!['ownerName'] ?? '';
      _phoneController.text = widget.initialData!['phone'] ?? '';
      _addressController.text = widget.initialData!['address'] ?? '';
      _descriptionController.text = widget.initialData!['description'] ?? '';
      _rentController.text = widget.initialData!['rent']?.toString() ?? '';
    } else {
      _fetchBusinessData();
    }
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _rentController.dispose();
    super.dispose();
  }

  Future<void> _fetchBusinessData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final uid = authProvider.authData?['user']['uid'];

      if (uid == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'User ID not found. Please log in again.';
        });
        return;
      }

      // Replace with your API base URL
      final baseUrl = APIConfig.baseUrl;
      final response = await http.get(
        Uri.parse('$baseUrl/profile/business?uid=$uid'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final businessData = data['data'];

        setState(() {
          _businessNameController.text = businessData['businessName'] ?? '';
          _ownerNameController.text = businessData['ownerName'] ?? '';
          _phoneController.text = businessData['phone'] ?? '';
          _addressController.text = businessData['address'] ?? '';
          _descriptionController.text = businessData['description'] ?? '';
          _rentController.text = businessData['rent']?.toString() ?? '';
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
        _errorMessage = 'Network error: ${e.toString()}';
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final uid = authProvider.authData?['user']['uid'];

      if (uid == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'User ID not found. Please log in again.';
        });
        return;
      }

      // Prepare data for update
      final updatedData = {
        'businessName': _businessNameController.text,
        'ownerName': _ownerNameController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'description': _descriptionController.text,
        'rent': int.tryParse(_rentController.text) ?? 0,
      };

      // Replace with your API base URL
      final baseUrl = APIConfig.baseUrl;
      final response = await http.post(
        Uri.parse('$baseUrl/profile/business?uid=$uid'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedData),
      );

      if (response.statusCode == 200) {
        setState(() {
          _isLoading = false;
        });

        if (!mounted) return;

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(
          context,
          true,
        ); // Return true to indicate successful update
      } else {
        final error = json.decode(response.body);
        setState(() {
          _isLoading = false;
          _errorMessage = error['error'] ?? 'Failed to update profile';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Network error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Business Profile'),
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildForm(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade800),
                    ),
                  ),
                ),

              _buildSectionTitle('Business Information'),
              _buildTextField(
                controller: _businessNameController,
                label: 'Business Name',
                icon: Icons.business,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter business name';
                  }
                  return null;
                },
              ),

              _buildTextField(
                controller: _ownerNameController,
                label: 'Owner Name',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter owner name';
                  }
                  return null;
                },
              ),

              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  if (value.length < 10) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),

              _buildSectionTitle('Location'),
              _buildTextField(
                controller: _addressController,
                label: 'Address',
                icon: Icons.location_on,
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter address';
                  }
                  return null;
                },
              ),

              _buildSectionTitle('Details'),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                icon: Icons.description,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),

              _buildTextField(
                controller: _rentController,
                label: 'Monthly Rent (₹)',
                icon: Icons.currency_rupee,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter monthly rent';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),
              _buildUpdateButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.indigo,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.indigo),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.indigo, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
      ),
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _updateProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child:
            _isLoading
                ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                )
                : const Text(
                  'Update Profile',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
      ),
    );
  }
}
