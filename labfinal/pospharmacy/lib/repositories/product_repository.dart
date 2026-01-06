import '../database/sqlite_helper.dart';
import '../models/product_model.dart';

class ProductRepository {
  // Get all products
  Future<List<ProductModel>> getAllProducts() async {
    final data = await SQLiteHelper.getProducts();
    return data.map((e) => ProductModel.fromMap(e)).toList();
  }

  // Add product
  Future<void> addProduct(ProductModel product) async {
    await SQLiteHelper.insertProduct(product.toMap());
  }

  // Update product
  Future<void> updateProduct(ProductModel product) async {
    await SQLiteHelper.updateProduct(product.id!, product.toMap());
  }

  // Delete product
  Future<void> deleteProduct(int id) async {
    await SQLiteHelper.deleteProduct(id);
  }

  // Get unsynced products for offline sync
  Future<List<ProductModel>> getUnsyncedProducts() async {
    final data = await SQLiteHelper.getUnsyncedProducts();
    return data.map((e) => ProductModel.fromMap(e)).toList();
  }

  Future<void> markAsSynced(int id) async {
    await SQLiteHelper.markProductAsSynced(id);
  }
}
