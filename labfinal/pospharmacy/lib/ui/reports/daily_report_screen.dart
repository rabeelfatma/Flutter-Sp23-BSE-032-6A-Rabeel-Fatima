import 'package:flutter/material.dart';
import '../../repositories/sales_repository.dart';
import '../../models/sale_model.dart';
import '../../widgets/empty_state.dart';

class DailyReportScreen extends StatefulWidget {
  const DailyReportScreen({super.key});

  @override
  State<DailyReportScreen> createState() => _DailyReportScreenState();
}

class _DailyReportScreenState extends State<DailyReportScreen> {
  final SalesRepository _repository = SalesRepository();

  List<SaleModel> sales = [];
  double totalAmount = 0;

  @override
  void initState() {
    super.initState();
    _loadDailySales();
  }

  Future<void> _loadDailySales() async {
    final today = DateTime.now();
    final result = await _repository.getDailySales(today);

    double sum = 0;
    for (var s in result) {
      sum += s.amount;
    }

    setState(() {
      sales = result;
      totalAmount = sum;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daily Sales Report")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: sales.isEmpty
            ? const EmptyState(
          message: "No sales today",
          icon: Icons.today,
        )
            : Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: sales.length,
                itemBuilder: (_, index) {
                  final s = sales[index];
                  return ListTile(
                    leading: const Icon(Icons.shopping_cart),
                    title: Text("Sale #${s.id}"),
                    subtitle:
                    Text("Amount: \$${s.amount.toStringAsFixed(2)}"),
                    trailing: Text(s.datetime),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Total Sales Today: \$${totalAmount.toStringAsFixed(2)}",
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
