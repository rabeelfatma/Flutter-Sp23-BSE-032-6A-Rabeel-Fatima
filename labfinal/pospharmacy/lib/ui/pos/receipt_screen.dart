import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/product_model.dart';

class ReceiptScreen extends StatelessWidget {
  final Map<int, int> cart;
  final List<ProductModel> products;
  final double totalAmount;

  const ReceiptScreen({
    super.key,
    required this.cart,
    required this.products,
    required this.totalAmount,
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
      appBar: AppBar(title: Text('Receipt')), // removed const
      body: Padding(
        padding: EdgeInsets.all(16), // removed const
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Receipt',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), // removed const
            SizedBox(height: 20), // removed const
            Expanded(
              child: ListView(
                children: cart.entries.map((entry) {
                  final product =
                  products.firstWhere((p) => p.id == entry.key);
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 4), // removed const
                    child: Text(
                      '${product.name} x${entry.value} = \$${(product.price * entry.value).toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 16), // removed const
                    ),
                  );
                }).toList(),
              ),
            ),
            Divider(), // removed const
            Text('Total: \$${totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)), // removed const
            SizedBox(height: 20), // removed const
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: _sharePDF,
                  child: Text('Share as PDF'), // removed const
                ),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.popUntil(context, (route) => route.isFirst),
                  child: Text('Done'), // removed const
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
