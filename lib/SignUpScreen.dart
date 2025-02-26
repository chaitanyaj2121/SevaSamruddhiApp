import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for business registration fields
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _rentController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _registerBusiness() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final url = Uri.parse("http://192.168.166.11:8080/signup/business");
    final bodyData = {
      "businessName": _businessNameController.text.trim(),
      "ownerName": _ownerNameController.text.trim(),
      "address": _addressController.text.trim(),
      "phone": _phoneController.text.trim(),
      "rent": _rentController.text.trim(),
      "email": _emailController.text.trim(),
      "description": _descriptionController.text.trim(),
      "password": _passwordController.text.trim(),
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(bodyData),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data["success"] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data["message"])));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Registration failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Business Sign Up")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _businessNameController,
                decoration: _inputDecoration(
                  "Business Name",
                  icon: Icons.business,
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ownerNameController,
                decoration: _inputDecoration("Owner Name", icon: Icons.person),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: _inputDecoration(
                  "Address",
                  icon: Icons.location_on,
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: _inputDecoration("Phone", icon: Icons.phone),
                keyboardType: TextInputType.phone,
                validator:
                    (value) =>
                        value == null || value.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _rentController,
                decoration: _inputDecoration(
                  "FeesMonthly",
                  icon: Icons.attach_money,
                ),
                keyboardType: TextInputType.number,
                validator:
                    (value) =>
                        value == null || value.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: _inputDecoration("Email", icon: Icons.email),
                keyboardType: TextInputType.emailAddress,
                validator:
                    (value) =>
                        value == null || value.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: _inputDecoration(
                  "Description",
                  icon: Icons.description,
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: _inputDecoration("Password", icon: Icons.lock),
                obscureText: true,
                validator:
                    (value) =>
                        value == null || value.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _registerBusiness,
                      child: const Text("Register Business"),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
