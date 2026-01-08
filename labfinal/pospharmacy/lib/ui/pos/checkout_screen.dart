import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database/sqlite_helper.dart';
import '../../models/product_model.dart';
import '../../models/sale_model.dart';
import '../../models/sale_item_model.dart';
import '../../providers/cart_provider.dart';
import '../../repositories/sales_repository.dart';
import 'receipt_screen.dart';

class CheckoutScreen extends StatelessWidget {
  final List<ProductModel> products;

  const CheckoutScreen({super.key, required this.products});

  /// Calculate total price of cart
  double total(Map<int, int> cart) {
    double sum = 0;
    cart.forEach((id, qty) {
      final product = products.firstWhere(
            (e) => e.id == id,
        orElse: () => throw Exception("Product with id $id not found"),
      );
      sum += product.price * qty;
    });
    return sum;
  }

  Future<void> _confirmSale(BuildContext context) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final cart = Map<int, int>.from(cartProvider.cart);

    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cart is empty")),
      );
      return;
    }

    final now = DateTime.now();
    final salesRepo = SalesRepository();

    // Create SaleModel (DB will generate ID)
    final sale = SaleModel(
      id: null,
      amount: total(cart),
      datetime: now.toIso8601String(),
      customerId: 0, // Use 0 if no customer selected
      synced: 0,
    );

    // Prepare SaleItems
    final items = cart.entries.map((entry) {
      final product = products.firstWhere(
            (p) => p.id == entry.key,
        orElse: () => throw Exception("Product with id ${entry.key} not found"),
      );
      return SaleItemModel(
        id: null,
        saleId: 0, // placeholder; repository will update with real saleId
        productId: product.id!,
        quantity: entry.value,
        price: product.price,
      );
    }).toList();

    // Insert sale and items via repository
    await salesRepo.addSale(sale, items: items);

    // Update product stock
    for (var entry in cart.entries) {
      final product = products.firstWhere((p) => p.id == entry.key);
      await SQLiteHelper.updateProductStock(
        product.id!,
        product.stock - entry.value,
      );
    }

    // Clear cart
    cartProvider.clearCart();

    // Navigate to receipt screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ReceiptScreen(
          cart: cart,
          products: products,
          totalAmount: total(cart),
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
