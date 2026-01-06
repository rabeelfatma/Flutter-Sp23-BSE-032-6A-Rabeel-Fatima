import 'package:flutter/material.dart';
import '../../database/sqlite_helper.dart';
import '../../models/ledger_model.dart';

class AddLedgerEntryScreen extends StatefulWidget {
  final LedgerModel? entry;
  const AddLedgerEntryScreen({super.key, this.entry});

  @override
  State<AddLedgerEntryScreen> createState() => _AddLedgerEntryScreenState();
}

class _AddLedgerEntryScreenState extends State<AddLedgerEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _descriptionController.text = widget.entry!.description;
      _amountController.text = widget.entry!.amount.toString();
      _selectedDate = DateTime.parse(widget.entry!.date);
    }
  }

  void _saveEntry() async {
    if (_formKey.currentState!.validate()) {
      final entry = LedgerModel(
        id: widget.entry?.id,
        description: _descriptionController.text,
        amount: double.parse(_amountController.text),
        date: _selectedDate.toIso8601String(),
      );

      if (widget.entry == null) {
        await SQLiteHelper.insertLedgerEntry(entry.toMap());
      } else {
        await SQLiteHelper.updateLedgerEntry(entry.id!, entry.toMap());
      }

      Navigator.pop(context);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.entry == null ? "Add Ledger Entry" : "Edit Ledger Entry")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                validator: (value) => value == null || value.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Amount"),
                validator: (value) => value == null || value.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text("Date: ${_selectedDate.toLocal().toString().split(' ')[0]}"),
                  TextButton(
                    onPressed: _pickDate,
                    child: const Text("Pick Date"),
                  )
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveEntry,
                child: const Text("Save Entry"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
