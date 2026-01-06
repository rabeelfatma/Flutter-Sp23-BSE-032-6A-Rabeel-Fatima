import 'package:flutter/material.dart';
import '../database/sqlite_helper.dart';
import '../models/ledger_model.dart';

class LedgerProvider extends ChangeNotifier {
  List<LedgerModel> _entries = [];

  List<LedgerModel> get entries => _entries;

  Future<void> loadLedger() async {
    final data = await SQLiteHelper.getLedgerEntries();
    _entries = data.map((e) => LedgerModel.fromMap(e)).toList();
    notifyListeners();
  }

  Future<void> addEntry(LedgerModel entry) async {
    await SQLiteHelper.insertLedgerEntry(entry.toMap());
    await loadLedger();
  }

  Future<void> updateEntry(LedgerModel entry) async {
    await SQLiteHelper.updateLedgerEntry(entry.id!, entry.toMap());
    await loadLedger();
  }

  Future<void> deleteEntry(int id) async {
    await SQLiteHelper.deleteLedgerEntry(id);
    await loadLedger();
  }
}
