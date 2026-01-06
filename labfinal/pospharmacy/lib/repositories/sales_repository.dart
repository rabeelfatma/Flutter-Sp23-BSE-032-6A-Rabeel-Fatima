import '../database/sqlite_helper.dart';

class SalesRepository {
  // Insert sale
  Future<void> addSale(Map<String, dynamic> sale) async {
    await SQLiteHelper.insertSale(sale);
  }

  // Get all sales
  Future<List<Map<String, dynamic>>> getAllSales() async {
    return await SQLiteHelper.getSales();
  }

  // Get unsynced sales
  Future<List<Map<String, dynamic>>> getUnsyncedSales() async {
    return await SQLiteHelper.getUnsyncedSales();
  }

  // Mark sale as synced
  Future<void> markAsSynced(int id) async {
    await SQLiteHelper.markSaleAsSynced(id);
  }

  // Get customer-specific sales history
  Future<List<Map<String, dynamic>>> getCustomerSales(int customerId) async {
    return await SQLiteHelper.getCustomerHistory(customerId);
  }
}
