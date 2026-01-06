import 'package:flutter/material.dart';
import '../../database/sqlite_helper.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../widgets/empty_state.dart'; // fixed import

class SalesChartWidget extends StatefulWidget {
  const SalesChartWidget({super.key});

  @override
  State<SalesChartWidget> createState() => _SalesChartWidgetState();
}

class _SalesChartWidgetState extends State<SalesChartWidget> {
  List<Map<String, dynamic>> sales = [];

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    final list = await SQLiteHelper.getSales();
    setState(() => sales = list);
  }

  @override
  Widget build(BuildContext context) {
    if (sales.isEmpty) {
      return const EmptyState(
        message: "No sales yet",
        icon: Icons.bar_chart,
      );
    }

    // Daily sales for last 7 days
    final Map<String, int> dailySales = {};
    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final day = DateTime(now.year, now.month, now.day - i);
      final key = '${day.day}/${day.month}';
      dailySales[key] = sales.where((s) {
        final date = DateTime.parse(s['datetime']);
        return date.year == day.year &&
            date.month == day.month &&
            date.day == day.day;
      }).length;
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: (dailySales.values.isEmpty
                ? 1
                : dailySales.values.reduce((a, b) => a > b ? a : b))
                .toDouble() +
                2,
            barGroups: dailySales.entries
                .map(
                  (e) => BarChartGroupData(
                x: int.parse(e.key.split('/')[0]),
                barRods: [
                  BarChartRodData(
                    toY: e.value.toDouble(),
                    color: Colors.blue,
                  )
                ],
              ),
            )
                .toList(),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 30),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final key = dailySales.keys.firstWhere(
                          (k) => int.parse(k.split('/')[0]) == value.toInt(),
                      orElse: () => '',
                    );
                    return Text(key);
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
