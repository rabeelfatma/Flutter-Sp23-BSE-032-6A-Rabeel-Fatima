import 'package:flutter/material.dart';
import '../../models/product_model.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductModel product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${product.name}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Price: \$${product.price}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Stock: ${product.stock}', style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
