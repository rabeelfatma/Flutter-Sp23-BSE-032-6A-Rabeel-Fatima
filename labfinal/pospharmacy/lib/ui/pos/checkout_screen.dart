import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database/sqlite_helper.dart';
import '../../models/product_model.dart';
import '../../models/sale_model.dart';
import '../../models/sale_item_model.dart';
import '../../providers/cart_provider.dart';
import '../../repositories/sales_repository.dart';
import 'receipt_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<ProductModel> products;

  const CheckoutScreen({super.key, required this.products});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  double discount = 0; // in percentage
  double tax = 0; // in percentage

  double total(Map<int, int> cart) {
    double sum = 0;
    cart.forEach((id, qty) {
      final product = widget.products.firstWhere(
            (e) => e.id == id,
        orElse: () => throw Exception("Product with id $id not found"),
      );
      sum += product.price * qty;
    });

    sum = sum - (sum * discount / 100); // apply discount
    sum = sum + (sum * tax / 100); // apply tax
    return sum;
  }

  Future<void> _confirmSale() async {
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

    // Create SaleModel
    final sale = SaleModel(
      id: null,
      amount: total(cart),
      datetime: now.toIso8601String(),
      customerId: 0, // Use 0 if no customer selected
      synced: 0,
    );

    // Prepare SaleItems
    final items = cart.entries.map((entry) {
      final product = widget.products.firstWhere((p) => p.id == entry.key);
      return SaleItemModel(
        id: null,
        saleId: 0, // placeholder; repository will update
        productId: product.id!,
        quantity: entry.value,
        price: product.price,
      );
    }).toList();

    // Insert sale and items via repository
    await salesRepo.addSale(sale, items: items);

    // Update product stock
    for (var entry in cart.entries) {
      final product = widget.products.firstWhere((p) => p.id == entry.key);
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
          products: widget.products,
          totalAmount: total(cart),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: cartProvider.items.map((item) {
                  return ListTile(
                    title: Text(item.name),
                    subtitle: Text("Price: \$${item.price} | Stock: ${item.stock}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () => cartProvider.decreaseItem(item.productId),
                        ),
                        Text('${item.quantity}'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => cartProvider.addItem(
                              item.productId, item.price, item.name, item.stock),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => cartProvider.removeItem(item.productId),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Discount %",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => setState(() => discount = double.tryParse(v) ?? 0),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Tax %",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => setState(() => tax = double.tryParse(v) ?? 0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Total: \$${total(cartProvider.cart).toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _confirmSale,
              child: const Text("Confirm Sale"),
            ),
          ],
        ),
      ),
    );
  }
}
