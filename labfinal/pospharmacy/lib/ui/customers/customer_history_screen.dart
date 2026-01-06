import 'package:flutter/material.dart';
import '../../models/customer_model.dart';
import '../../database/sqlite_helper.dart';

class CustomerHistoryScreen extends StatefulWidget {
  final CustomerModel customer;
  const CustomerHistoryScreen({super.key, required this.customer});

  @override
  State<CustomerHistoryScreen> createState() => _CustomerHistoryScreenState();
}

class _CustomerHistoryScreenState extends State<CustomerHistoryScreen> {
  List<Map<String, dynamic>> history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final list =
    await SQLiteHelper.getCustomerHistory(widget.customer.id!);
    setState(() {
      history = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.customer.name} History')),
      body: history.isEmpty
          ? const Center(child: Text('No history available'))
          : ListView.builder(
        itemCount: history.length,
        itemBuilder: (_, index) {
          final h = history[index];
          return ListTile(
            title: Text(h['description']),
            subtitle: Text('Amount: \$${h['amount']}'),
            trailing: Text(h['date']),
          );
        },
      ),
    );
  }
}
