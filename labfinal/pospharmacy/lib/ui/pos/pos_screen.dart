import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database/sqlite_helper.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/empty_state.dart';
import 'checkout_screen.dart';

class POSScreen extends StatefulWidget {
  const POSScreen({super.key});

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  List<ProductModel> products = [];

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

  void _addToCart(Map<int, int> cart, ProductModel product) {
    if (product.id == null) return;
    setState(() {
      cart[product.id!] = (cart[product.id!] ?? 0) + 1;
    });
  }

  void _openCart(Map<int, int> cart) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(products: products),
      ),
    ).then((_) => _loadProducts());
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cart = cartProvider.cart;

    return Scaffold(
      appBar: AppBar(
        title: const Text("POS"),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: cart.isEmpty ? null : () => _openCart(cart),
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
            mainAxisSpacing: 10),
        itemCount: products.length,
        itemBuilder: (_, i) {
          final p = products[i];
          return Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(p.name,
                    style:
                    const TextStyle(fontWeight: FontWeight.bold)),
                Text("Price: \$${p.price}"),
                Text("Stock: ${p.stock}"),
                ElevatedButton(
                  onPressed: () => _addToCart(cart, p),
                  child: const Text("Add"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
