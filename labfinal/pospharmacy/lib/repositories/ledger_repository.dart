import '../database/sqlite_helper.dart';
import '../models/ledger_model.dart';

class LedgerRepository {
  /// 🔹 Get all ledger entries
  Future<List<LedgerModel>> getAllEntries() async {
    final data = await SQLiteHelper.getLedgerEntries();
    return data.map((e) => LedgerModel.fromMap(e)).toList();
  }

  /// 🔹 Add a new ledger entry
  Future<void> addEntry(LedgerModel entry) async {
    await SQLiteHelper.insertLedgerEntry(entry.toMap());
  }

  /// 🔹 Update an existing ledger entry
  Future<void> updateEntry(LedgerModel entry) async {
    if (entry.id != null) {
      await SQLiteHelper.updateLedgerEntry(entry.id!, entry.toMap());
    } else {
      throw Exception("Ledger entry ID is null, cannot update.");
    }
  }

  /// 🔹 Delete a ledger entry by ID
  Future<void> deleteEntry(int id) async {
    await SQLiteHelper.deleteLedgerEntry(id);
  }

  /// 🔹 Get total outstanding balance (debit - credit)
  Future<double> getOutstandingBalance() async {
    return await SQLiteHelper.getOutstandingBalance();
  }

  /// 🔹 Optional: Get only debit entries
  Future<List<LedgerModel>> getDebits() async {
    final data = await SQLiteHelper.getLedgerEntries();
    return data
        .map((e) => LedgerModel.fromMap(e))
        .where((e) => e.type == 'debit')
        .toList();
  }

  /// 🔹 Optional: Get only credit entries
  Future<List<LedgerModel>> getCredits() async {
    final data = await SQLiteHelper.getLedgerEntries();
    return data
        .map((e) => LedgerModel.fromMap(e))
        .where((e) => e.type == 'credit')
        .toList();
  }
}
