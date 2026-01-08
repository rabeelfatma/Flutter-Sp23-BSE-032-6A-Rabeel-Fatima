import '../database/sqlite_helper.dart';
import '../models/sale_model.dart';
import '../models/sale_item_model.dart';

class SalesRepository {
  /// Add sale with items
  Future<void> addSale(SaleModel sale, {List<SaleItemModel>? items}) async {
    final saleId = await SQLiteHelper.insertSale(sale.toMap());

    if (items != null) {
      for (var item in items) {
        final itemMap = item.copyWith(saleId: saleId).toMap();
        await SQLiteHelper.insertSaleItem(itemMap);

        // Update stock after sale
        final product = await SQLiteHelper.getProductById(item.productId);
        if (product != null) {
          int newStock = product['stock'] - item.quantity;
          await SQLiteHelper.updateProductStock(item.productId, newStock);
          await SQLiteHelper.insertStockHistory({
            'product_id': item.productId,
            'change': item.quantity,
            'type': 'out',
            'date': DateTime.now().toIso8601String(),
          });
        }
      }
    }
  }

  /// Get all sales
  Future<List<SaleModel>> getAllSales() async {
    final data = await SQLiteHelper.getSales();
    return data.map((e) => SaleModel.fromMap(e)).toList();
  }

  /// Daily sales
  Future<List<SaleModel>> getDailySales(DateTime date) async {
    final data = await SQLiteHelper.getSales();
    final filtered = data.where((s) {
      final saleDate = DateTime.parse(s['datetime']);
      return saleDate.year == date.year &&
          saleDate.month == date.month &&
          saleDate.day == date.day;
    }).toList();
    return filtered.map((e) => SaleModel.fromMap(e)).toList();
  }

  /// Monthly sales
  Future<List<SaleModel>> getMonthlySales(DateTime date) async {
    final data = await SQLiteHelper.getSales();
    final filtered = data.where((s) {
      final saleDate = DateTime.parse(s['datetime']);
      return saleDate.year == date.year && saleDate.month == date.month;
    }).toList();
    return filtered.map((e) => SaleModel.fromMap(e)).toList();
  }

  /// Sale items by sale ID
  Future<List<SaleItemModel>> getSaleItems(int saleId) async {
    final data = await SQLiteHelper.getSaleItemsBySale(saleId);
    return data.map((e) => SaleItemModel.fromMap(e)).toList();
  }

  /// Unsynced sales
  Future<List<SaleModel>> getUnsyncedSales() async {
    final data = await SQLiteHelper.getUnsyncedSales();
    return data.map((e) => SaleModel.fromMap(e)).toList();
  }

  /// Mark sale as synced
  Future<void> markAsSynced(int id) async {
    await SQLiteHelper.markSaleAsSynced(id);
  }

  /// Customer history
  Future<List<SaleModel>> getCustomerSales(int customerId) async {
    final data = await SQLiteHelper.getCustomerHistory(customerId);
    return data.map((e) => SaleModel.fromMap(e)).toList();
  }
}
