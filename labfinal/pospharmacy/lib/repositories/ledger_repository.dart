import '../database/sqlite_helper.dart';
import '../models/ledger_model.dart';

class LedgerRepository {
  // Get all ledger entries
  Future<List<LedgerModel>> getAllEntries() async {
    final data = await SQLiteHelper.getLedgerEntries();
    return data.map((e) => LedgerModel.fromMap(e)).toList();
  }

  // Add ledger entry
  Future<void> addEntry(LedgerModel entry) async {
    await SQLiteHelper.insertLedgerEntry(entry.toMap());
  }

  // Update ledger entry
  Future<void> updateEntry(LedgerModel entry) async {
    await SQLiteHelper.updateLedgerEntry(entry.id!, entry.toMap());
  }

  // Delete ledger entry
  Future<void> deleteEntry(int id) async {
    await SQLiteHelper.deleteLedgerEntry(id);
  }
}
