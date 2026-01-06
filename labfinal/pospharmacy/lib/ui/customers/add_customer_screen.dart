import 'package:flutter/material.dart';
import '../../database/sqlite_helper.dart';
import '../../models/customer_model.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  void _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    final customer = CustomerModel(
      id: null,
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
    );

    await SQLiteHelper.insertCustomer(customer.toMap());

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Customer added')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Customer')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v == null || v.isEmpty ? 'Enter name' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v == null || v.isEmpty ? 'Enter email' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: (v) => v == null || v.isEmpty ? 'Enter phone' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveCustomer,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
