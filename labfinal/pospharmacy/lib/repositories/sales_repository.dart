import '../database/sqlite_helper.dart';
import '../models/sale_model.dart';
import '../models/sale_item_model.dart';

class SalesRepository {
  /// Add sale with optional sale items
  Future<void> addSale(SaleModel sale, {List<SaleItemModel>? items}) async {
    int saleId = await SQLiteHelper.insertSale(sale.toMap());

    // Insert sale items if provided
    if (items != null) {
      for (var item in items) {
        var itemMap = item.copyWith(saleId: saleId).toMap();
        await SQLiteHelper.insertSaleItem(itemMap);
      }
    }
  }

  /// Get all sales
  Future<List<SaleModel>> getAllSales() async {
    final data = await SQLiteHelper.getSales();
    return data.map((e) => SaleModel.fromMap(e)).toList();
  }

  /// Get sale items for a specific sale
  Future<List<SaleItemModel>> getSaleItems(int saleId) async {
    final data = await SQLiteHelper.getSaleItemsBySale(saleId);
    return data.map((e) => SaleItemModel.fromMap(e)).toList();
  }

  /// Get unsynced sales
  Future<List<SaleModel>> getUnsyncedSales() async {
    final data = await SQLiteHelper.getUnsyncedSales();
    return data.map((e) => SaleModel.fromMap(e)).toList();
  }

  /// Mark sale as synced
  Future<void> markAsSynced(int id) async {
    await SQLiteHelper.markSaleAsSynced(id);
  }

  /// Customer-specific sales history
  Future<List<SaleModel>> getCustomerSales(int customerId) async {
    final data = await SQLiteHelper.getCustomerHistory(customerId);
    return data.map((e) => SaleModel.fromMap(e)).toList();
  }
}
