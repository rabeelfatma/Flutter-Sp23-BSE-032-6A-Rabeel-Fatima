import 'package:flutter/material.dart';
import '../../database/sqlite_helper.dart';
import '../../widgets/empty_state.dart';

class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  List<Map<String, dynamic>> sales = [];
  double totalAmount = 0;

  @override
  void initState() {
    super.initState();
    _loadMonthlySales();
  }

  Future<void> _loadMonthlySales() async {
    final allSales = await SQLiteHelper.getSales();
    final now = DateTime.now();
    final filtered = allSales.where((s) {
      final date = DateTime.parse(s['datetime']);
      return date.year == now.year && date.month == now.month;
    }).toList();

    double sum = 0;
    for (var s in filtered) sum += s['amount']?.toDouble() ?? 0;

    setState(() {
      sales = filtered;
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
            ? EmptyState(message: "No sales this month", icon: Icons.date_range)
            : Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: sales.length,
                itemBuilder: (_, index) {
                  final s = sales[index];
                  return ListTile(
                    title: Text(s['item']),
                    subtitle: Text("Amount: \$${s['amount']}"),
                    trailing: Text(s['datetime']),
                  );
                },
              ),
            ),
            Text(
              "Total Sales: \$${totalAmount.toStringAsFixed(2)}",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
