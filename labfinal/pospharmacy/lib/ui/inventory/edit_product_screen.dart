import 'package:flutter/material.dart';
import '../../database/sqlite_helper.dart';
import '../../models/product_model.dart';

class EditProductScreen extends StatefulWidget {
  final ProductModel product;
  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late double price;
  late int stock;

  @override
  void initState() {
    super.initState();
    name = widget.product.name;
    price = widget.product.price;
    stock = widget.product.stock;
  }

  void _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final updated = ProductModel(
          id: widget.product.id, name: name, price: price, stock: stock);
      await SQLiteHelper.updateProduct(widget.product.id!, updated.toMap());
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Product')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v!.isEmpty ? 'Enter name' : null,
                onSaved: (v) => name = v!,
              ),
              TextFormField(
                initialValue: price.toString(),
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v!.isEmpty ? 'Enter price' : null,
                onSaved: (v) => price = double.parse(v!),
              ),
              TextFormField(
                initialValue: stock.toString(),
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Enter stock' : null,
                onSaved: (v) => stock = int.parse(v!),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: _updateProduct, child: const Text('Update'))
            ],
          ),
        ),
      ),
    );
  }
}
