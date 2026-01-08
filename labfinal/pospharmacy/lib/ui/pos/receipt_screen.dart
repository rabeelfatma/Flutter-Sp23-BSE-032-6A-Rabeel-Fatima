import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/product_model.dart';

class ReceiptScreen extends StatelessWidget {
  final Map<int, int> cart;
  final List<ProductModel> products;
  final double totalAmount;
  final double discount; // added
  final double tax; // added

  const ReceiptScreen({
    super.key,
    required this.cart,
    required this.products,
    required this.totalAmount,
    this.discount = 0,
    this.tax = 0,
  });

  /// Share receipt as PDF
  Future<void> _sharePDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Receipt',
                style: pw.TextStyle(
                    fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            ...cart.entries.map((entry) {
              final product =
              products.firstWhere((p) => p.id == entry.key);
              return pw.Text(
                  '${product.name} x${entry.value} = \$${(product.price * entry.value).toStringAsFixed(2)}',
                  style: pw.TextStyle(fontSize: 16));
            }),
            pw.Divider(),
            if (discount > 0)
              pw.Text('Discount: $discount%',
                  style: pw.TextStyle(fontSize: 16)),
            if (tax > 0)
              pw.Text('Tax: $tax%', style: pw.TextStyle(fontSize: 16)),
            pw.Divider(),
            pw.Text('Total: \$${totalAmount.toStringAsFixed(2)}',
                style: pw.TextStyle(
                    fontSize: 20, fontWeight: pw.FontWeight.bold)),
          ],
        ),
      ),
    );

    await Printing.sharePdf(
        bytes: await pdf.save(), filename: 'receipt.pdf');
  }

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
            Expanded(
              child: ListView(
                children: cart.entries.map((entry) {
                  final product =
                  products.firstWhere((p) => p.id == entry.key);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      '${product.name} x${entry.value} = \$${(product.price * entry.value).toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                }).toList(),
              ),
            ),
            if (discount > 0)
              Text('Discount: $discount%', style: const TextStyle(fontSize: 16)),
            if (tax > 0)
              Text('Tax: $tax%', style: const TextStyle(fontSize: 16)),
            const Divider(),
            Text('Total: \$${totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: _sharePDF,
                  child: const Text('Share as PDF'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.popUntil(context, (route) => route.isFirst),
                  child: const Text('Done'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
