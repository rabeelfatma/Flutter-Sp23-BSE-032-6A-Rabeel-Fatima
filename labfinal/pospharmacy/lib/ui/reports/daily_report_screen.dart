import 'package:flutter/material.dart';
import '../../database/sqlite_helper.dart';
import '../../widgets/empty_state.dart';

class DailyReportScreen extends StatefulWidget {
  const DailyReportScreen({super.key});

  @override
  State<DailyReportScreen> createState() => _DailyReportScreenState();
}

class _DailyReportScreenState extends State<DailyReportScreen> {
  List<Map<String, dynamic>> sales = [];
  double totalAmount = 0;

  @override
  void initState() {
    super.initState();
    _loadDailySales();
  }

  Future<void> _loadDailySales() async {
    final allSales = await SQLiteHelper.getSales();
    final today = DateTime.now();
    final filtered = allSales.where((s) {
      final date = DateTime.parse(s['datetime']);
      return date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
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
      appBar: AppBar(title: const Text("Daily Sales Report")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: sales.isEmpty
            ? EmptyState(message: "No sales today", icon: Icons.today)
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
