import 'package:flutter/material.dart';
import '../../database/sqlite_helper.dart';
import '../../models/customer_model.dart';
import 'add_customer_screen.dart';
import 'customer_history_screen.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  List<CustomerModel> customers = [];

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    final list = await SQLiteHelper.getCustomers();
    setState(() {
      customers = list.map((e) => CustomerModel.fromMap(e)).toList();
    });
  }

  void _goToAddCustomer() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddCustomerScreen()),
    ).then((_) => _loadCustomers());
  }

  void _goToHistory(CustomerModel customer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerHistoryScreen(customer: customer),
      ),
    );
  }

  void _deleteCustomer(int id) async {
    await SQLiteHelper.deleteCustomer(id);
    _loadCustomers();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Customer deleted')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _goToAddCustomer,
          ),
        ],
      ),
      body: customers.isEmpty
          ? const Center(child: Text('No customers yet'))
          : ListView.builder(
        itemCount: customers.length,
        itemBuilder: (_, index) {
          final c = customers[index];
          return ListTile(
            title: Text(c.name),
            subtitle: Text(c.email),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.history),
                  onPressed: () => _goToHistory(c),
                  tooltip: 'View History',
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteCustomer(c.id!),
                  tooltip: 'Delete Customer',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
