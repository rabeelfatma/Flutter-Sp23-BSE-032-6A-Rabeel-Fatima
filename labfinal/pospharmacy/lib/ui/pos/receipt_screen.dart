import 'package:flutter/material.dart';
import '../../models/product_model.dart';

class ReceiptScreen extends StatelessWidget {
  final Map<int, int> cart;
  final List<ProductModel> products;
  final double total;

  const ReceiptScreen({super.key, required this.cart, required this.products, required this.total});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receipt')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Receipt',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ...cart.entries.map((e) {
              final product = products.firstWhere((p) => p.id == e.key);
              return Text(
                  '${product.name} x${e.value} = \$${(product.price * e.value).toStringAsFixed(2)}');
            }),
            const SizedBox(height: 20),
            Text('Total: \$${total.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                child: const Text('Done'))
          ],
        ),
      ),
    );
  }
}
