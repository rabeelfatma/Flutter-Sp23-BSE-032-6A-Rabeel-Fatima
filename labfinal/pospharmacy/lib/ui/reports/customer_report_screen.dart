import 'package:flutter/material.dart';
import '../../database/sqlite_helper.dart';
import '../../models/customer_model.dart';
import '../../widgets/empty_state.dart';

class CustomerReportScreen extends StatefulWidget {
  const CustomerReportScreen({super.key});

  @override
  State<CustomerReportScreen> createState() => _CustomerReportScreenState();
}

class _CustomerReportScreenState extends State<CustomerReportScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Customer Report")),
      body: customers.isEmpty
          ? EmptyState(message: "No customers available", icon: Icons.people)
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: customers.length,
        itemBuilder: (_, index) {
          final c = customers[index];
          return ListTile(
            title: Text(c.name),
            subtitle: Text("Email: ${c.email} | Phone: ${c.phone}"),
          );
        },
      ),
    );
  }
}
