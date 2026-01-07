import 'package:flutter/material.dart';
import '../../database/sqlite_helper.dart';
import '../../models/customer_model.dart';

class CustomerHistoryScreen extends StatefulWidget {
  final CustomerModel customer;

  const CustomerHistoryScreen({
    super.key,
    required this.customer,
  });

  @override
  State<CustomerHistoryScreen> createState() => _CustomerHistoryScreenState();
}

class _CustomerHistoryScreenState extends State<CustomerHistoryScreen> {
  List<Map<String, dynamic>> history = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final data =
    await SQLiteHelper.getCustomerHistory(widget.customer.id!);
    setState(() {
      history = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.customer.name} Purchase History'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : history.isEmpty
          ? const Center(child: Text('No purchase history found'))
          : ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          final h = history[index];
          return Card(
            margin: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(
                h['item'],
                style: const TextStyle(
                    fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Amount: \$${h['amount']}',
              ),
              trailing: Text(
                h['datetime'],
                style: const TextStyle(fontSize: 12),
              ),
            ),
          );
        },
      ),
    );
  }
}
