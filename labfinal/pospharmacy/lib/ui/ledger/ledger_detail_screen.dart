import 'package:flutter/material.dart';
import '../../models/ledger_model.dart';

class LedgerDetailScreen extends StatelessWidget {
  final LedgerModel entry;
  const LedgerDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ledger Details")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Description: ${entry.description}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            Text("Amount: \$${entry.amount}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            Text("Type: ${entry.type}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            Text("Date: ${entry.date.split('T')[0]}", style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
