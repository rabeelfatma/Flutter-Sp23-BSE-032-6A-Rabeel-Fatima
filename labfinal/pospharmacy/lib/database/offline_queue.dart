import 'sqlite_helper.dart';

class OfflineQueue {
  // Add product, sale, customer, ledger to offline queue
  static Future<void> addProduct(Map<String, dynamic> product) async {
    await SQLiteHelper.insertProduct(product);
  }

  static Future<void> addSale(Map<String, dynamic> sale) async {
    await SQLiteHelper.insertSale(sale);
  }

  static Future<void> addCustomer(Map<String, dynamic> customer) async {
    await SQLiteHelper.insertCustomer(customer);
  }

  static Future<void> addLedger(Map<String, dynamic> entry) async {
    await SQLiteHelper.insertLedgerEntry(entry);
  }

  // Fetch unsynced data
  static Future<List<Map<String, dynamic>>> getUnsyncedProducts() async {
    return SQLiteHelper.getProducts(); // mark with synced = 0 if needed
  }

  static Future<List<Map<String, dynamic>>> getUnsyncedSales() async {
    return SQLiteHelper.getSales();
  }

  static Future<List<Map<String, dynamic>>> getUnsyncedLedger() async {
    return SQLiteHelper.getLedgerEntries();
  }

  // Mark synced
  static Future<void> markProductSynced(int id) async {
    await SQLiteHelper.updateProductStock(id, 0); // optional
  }

  static Future<void> markSaleSynced(int id) async {
    // implement if needed
  }

  static Future<void> markLedgerSynced(int id) async {
    // implement if needed
  }
}
