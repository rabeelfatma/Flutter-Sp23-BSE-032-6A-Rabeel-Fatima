import 'package:flutter/material.dart';
import '../../database/sqlite_helper.dart';
import '../../models/product_model.dart';
import '../../widgets/empty_state.dart';
import 'cart_screen.dart';
import 'checkout_screen.dart';

class POSScreen extends StatefulWidget {
  const POSScreen({super.key});

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  List<ProductModel> products = [];
  Map<int, int> cart = {};

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final data = await SQLiteHelper.getProducts();
    setState(() {
      products = data.map((e) => ProductModel.fromMap(e)).toList();
    });
  }

  void _addToCart(ProductModel product) {
    if (product.id == null) return;

    setState(() {
      cart[product.id!] = (cart[product.id!] ?? 0) + 1;
    });
  }

  void _openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CartScreen(
          cart: cart,
          products: products,
          onCheckout: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CheckoutScreen(
                  cart: cart,
                  products: products,
                ),
              ),
            ).then((_) {
              cart.clear();
              _loadProducts();
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("POS"),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: cart.isEmpty ? null : _openCart,
          )
        ],
      ),
      body: products.isEmpty
          ? const EmptyState(
        message: "No products available",
        icon: Icons.inventory_2_outlined,
      )
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: products.length,
        itemBuilder: (_, i) {
          final p = products[i];
          return Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(p.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold)),
                Text("Price: \$${p.price}"),
                Text("Stock: ${p.stock}"),
                ElevatedButton(
                  onPressed: () => _addToCart(p),
                  child: const Text("Add"),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
