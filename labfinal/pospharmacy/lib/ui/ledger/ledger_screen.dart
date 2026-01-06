import 'package:flutter/material.dart';
import '../../database/sqlite_helper.dart';
import '../../models/ledger_model.dart';
import 'add_ledger_entry_screen.dart';
import 'ledger_detail_screen.dart';

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  List<LedgerModel> entries = [];

  @override
  void initState() {
    super.initState();
    _loadLedgerEntries();
  }

  Future<void> _loadLedgerEntries() async {
    final list = await SQLiteHelper.getLedgerEntries();
    setState(() {
      entries = list.map((e) => LedgerModel.fromMap(e)).toList();
    });
  }

  void _deleteEntry(int id) async {
    await SQLiteHelper.deleteLedgerEntry(id);
    _loadLedgerEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ledger"),
      ),
      body: entries.isEmpty
          ? const Center(child: Text("No ledger entries"))
          : ListView.builder(
        itemCount: entries.length,
        itemBuilder: (_, index) {
          final e = entries[index];
          return ListTile(
            title: Text(e.description),
            subtitle: Text("Amount: \$${e.amount} | Date: ${e.date}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddLedgerEntryScreen(entry: e),
                      ),
                    ).then((_) => _loadLedgerEntries());
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteEntry(e.id!),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LedgerDetailScreen(entry: e),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddLedgerEntryScreen()),
          ).then((_) => _loadLedgerEntries());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
