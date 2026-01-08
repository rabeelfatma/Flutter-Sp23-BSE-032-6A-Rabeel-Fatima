import 'package:flutter/material.dart';
import '../../repositories/sales_repository.dart';
import '../../models/sale_model.dart';
import '../../widgets/empty_state.dart';

class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  final SalesRepository _repository = SalesRepository();

  List<SaleModel> sales = [];
  double totalAmount = 0;

  @override
  void initState() {
    super.initState();
    _loadMonthlySales();
  }

  Future<void> _loadMonthlySales() async {
    final now = DateTime.now();
    final result = await _repository.getMonthlySales(now);

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
      appBar: AppBar(title: const Text("Monthly Sales Report")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: sales.isEmpty
            ? const EmptyState(
          message: "No sales this month",
          icon: Icons.date_range,
        )
            : Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: sales.length,
                itemBuilder: (_, index) {
                  final s = sales[index];
                  return ListTile(
                    leading: const Icon(Icons.receipt_long),
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
              "Total Sales This Month: \$${totalAmount.toStringAsFixed(2)}",
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
