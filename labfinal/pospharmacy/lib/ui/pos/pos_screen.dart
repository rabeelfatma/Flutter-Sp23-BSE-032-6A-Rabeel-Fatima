import 'package:flutter/material.dart';
import '../../database/sqlite_helper.dart';
import '../../models/product_model.dart';
import '../../widgets/empty_state.dart';
import 'cart_screen.dart';

class POSScreen extends StatefulWidget {
  const POSScreen({super.key});

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  List<ProductModel> products = [];
  Map<int, int> cart = {}; // productId -> quantity

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final list = await SQLiteHelper.getProducts();
    setState(() {
      products = list.map((e) => ProductModel.fromMap(e)).toList();
    });
  }

  void _addToCart(ProductModel product) {
    if (product.id == null) return;

    // Low stock warning
    if (product.stock <= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Low Stock Alert: ${product.name} stock is ${product.stock}"),
          backgroundColor: Colors.orange,
        ),
      );
    }

    setState(() {
      if (cart.containsKey(product.id)) {
        cart[product.id!] = cart[product.id!]! + 1;
      } else {
        cart[product.id!] = 1;
      }
    });
  }

  void _goToCart() {
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cart is empty! Please add products first."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CartScreen(
          cart: cart,
          products: products,
          onCheckout: () async {
            if (cart.isEmpty) return;

            final now = DateTime.now().toIso8601String();

            // 1️⃣ Update stock
            for (var entry in cart.entries) {
              final product = products.firstWhere((p) => p.id == entry.key);
              final newStock = product.stock - entry.value;
              await SQLiteHelper.updateProductStock(product.id!, newStock);
            }

            // 2️⃣ Insert sales
            for (var entry in cart.entries) {
              final product = products.firstWhere((p) => p.id == entry.key);
              await SQLiteHelper.insertSale({
                'item': product.name,
                'amount': product.price * entry.value,
                'customer_id': null, // optional
                'datetime': now,
                'synced': 0,
              });
            }

            // 3️⃣ Reload products in POSScreen
            _loadProducts();

            // 4️⃣ Clear cart
            setState(() {
              cart.clear();
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Checkout successful!"),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
      ),
    ).then((_) => setState(() {})); // reload after returning
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("POS"),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: _goToCart,
          ),
        ],
      ),
      body: products.isEmpty
          ? const EmptyState(
        message: "No products available",
        icon: Icons.inventory_2_outlined,
      )
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: products.length,
        itemBuilder: (_, index) {
          final p = products[index];
          return Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    p.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Price: \$${p.price.toStringAsFixed(2)}'),
                  Text('Stock: ${p.stock}'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _addToCart(p),
                    child: const Text("Add to Cart"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: cart.isNotEmpty
          ? Container(
        padding: const EdgeInsets.all(8),
        color: Colors.blueGrey.shade50,
        child: ElevatedButton(
          onPressed: () {
            // Trigger same checkout logic as CartScreen
            if (cart.isEmpty) return;
            _goToCart();
          },
          child: Text(
              "Checkout (${cart.values.fold(0, (a, b) => a + b)} items)"),
        ),
      )
          : null,
    );
  }
}
