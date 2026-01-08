import 'package:flutter/material.dart';
import '../database/sqlite_helper.dart';
import '../models/product_model.dart';

class InventoryProvider extends ChangeNotifier {
  List<ProductModel> _products = [];

  /// Full product list
  List<ProductModel> get products => _products;

  /// Low stock products (<5)
  List<ProductModel> get lowStock =>
      _products.where((p) => p.stock < 5).toList();

  /// Load all products from database
  Future<void> loadProducts() async {
    final data = await SQLiteHelper.getProducts();
    _products = data.map((e) => ProductModel.fromMap(e)).toList();

    // 🔹 Notify listeners to refresh any widget listening (dashboard, low stock)
    notifyListeners();
  }

  /// Add a new product and refresh
  Future<void> addProduct(ProductModel product) async {
    await SQLiteHelper.insertProduct(product.toMap());

    // 🔹 Reload products and notify widgets
    await loadProducts();
  }

  /// Update product and refresh
  Future<void> updateProduct(ProductModel product) async {
    await SQLiteHelper.updateProduct(product.id!, product.toMap());

    // 🔹 Reload products and notify widgets
    await loadProducts();
  }

  /// Delete product and refresh
  Future<void> deleteProduct(int id) async {
    await SQLiteHelper.deleteProduct(id);

    // 🔹 Reload products and notify widgets
    await loadProducts();
  }
}
