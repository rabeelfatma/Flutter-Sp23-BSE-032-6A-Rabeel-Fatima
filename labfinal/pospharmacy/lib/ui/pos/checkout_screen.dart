import 'package:flutter/material.dart';
import '../../database/sqlite_helper.dart';
import '../../models/product_model.dart';
import '../../services/notification_service.dart';
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
      final product = products.firstWhere((p) => p.id == id);
      sum += product.price * qty;
    });
    return sum;
  }

  Future<void> _confirmSale(BuildContext context) async {
    for (final e in cart.entries) {
      final product = products.firstWhere((p) => p.id == e.key);
      await SQLiteHelper.insertSale({
        'item': product.name,
        'amount': product.price * e.value,
        'synced': 0,
        'datetime': DateTime.now().toIso8601String(),
      });
    }

    NotificationService().showNotification(
      context: context,
      title: "Sale Successful",
      body: "Receipt generated successfully",
    );

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
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () => _confirmSale(context),
          child: const Text('Confirm Sale'),
        ),
      ),
    );
  }
}
