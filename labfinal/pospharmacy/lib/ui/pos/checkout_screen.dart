import 'package:flutter/material.dart';
import '../../database/sqlite_helper.dart';
import '../../models/product_model.dart';
import 'receipt_screen.dart';

class CheckoutScreen extends StatelessWidget {
  final Map<int, int> cart;
  final List<ProductModel> products;

  const CheckoutScreen({
    super.key,
    required this.cart,
    required this.products,
  });

  double get total {
    double sum = 0;
    cart.forEach((id, qty) {
      final p = products.firstWhere((e) => e.id == id);
      sum += p.price * qty;
    });
    return sum;
  }

  Future<void> _confirmSale(BuildContext context) async {
    final now = DateTime.now().toIso8601String();

    for (final entry in cart.entries) {
      final product = products.firstWhere((p) => p.id == entry.key);

      await SQLiteHelper.insertSale({
        'item': product.name,
        'amount': product.price * entry.value,
        'datetime': now,
        'synced': 0,
      });

      await SQLiteHelper.updateProductStock(
        product.id!,
        product.stock - entry.value,
      );
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ReceiptScreen(
          cart: cart,
          products: products,
          total: total,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _confirmSale(context),
          child: const Text("Confirm Sale"),
        ),
      ),
    );
  }
}
