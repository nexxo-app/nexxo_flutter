import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ExpenseTrendChart extends StatelessWidget {
  final Map<int, Map<String, double>>
  data; // {monthIndex: {'income': x, 'expense': y}}

  const ExpenseTrendChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Sort keys to ensure chronological order
    final sortedKeys = data.keys.toList()..sort();

    // Calculate max Y for scaling
    double maxY = 0;
    for (var key in sortedKeys) {
      double income = data[key]?['income'] ?? 0;
      double expense = data[key]?['expense'] ?? 0;
      if (income > maxY) maxY = income;
      if (expense > maxY) maxY = expense;
    }
    maxY = maxY * 1.2; // Add some buffer

    return BarChart(
      BarChartData(
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            // tooltipBgColor: Colors.blueGrey, // Deprecated in newer versions, use getTooltipColor
            getTooltipColor: (_) => Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String type = rodIndex == 0 ? 'Receita' : 'Despesa';
              return BarTooltipItem(
                '$type\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: 'R\$ ${rod.toY.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white, // widget.touchedBarColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                // value is the index in sortedKeys
                int index = value.toInt();
                if (index < 0 || index >= sortedKeys.length)
                  return const SizedBox.shrink();

                // Assuming keys are 1-12 for month index?
                // Wait, caller should probably pass months relative to something or just 0-5
                // Let's assume keys are absolute months (1-12) or something we can map to name
                // Actually easier if key is index 0-5

                // Let's rely on the Logic passing 0 to N-1
                // But wait, to show Month Name we need the actual month index.
                // Let's assume data keys are DateTime.month (1-12).
                // Or better, Map<DateTime, ...> but Map keys are messy.
                // Let's assume the key is the month integer (1-12).

                // Get the month number stored in the data map
                int monthKey = sortedKeys[index];
                double? monthVal = data[monthKey]?['month'];

                // Fallback or safety check
                if (monthVal == null) return const SizedBox.shrink();

                int month = monthVal.toInt();
                // Ensure month is 1-12
                if (month < 1 || month > 12) return const SizedBox.shrink();

                const months = [
                  'Jan',
                  'Fev',
                  'Mar',
                  'Abr',
                  'Mai',
                  'Jun',
                  'Jul',
                  'Ago',
                  'Set',
                  'Out',
                  'Nov',
                  'Dez',
                ];
                return SideTitleWidget(
                  meta: meta,
                  space: 8,
                  child: Text(
                    months[month - 1],
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 5 > 0 ? maxY / 5 : 100,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withAlpha(26), // 0.1
            strokeWidth: 1,
          ),
        ),
        barGroups: sortedKeys.asMap().entries.map((entry) {
          int index = entry.key; // 0, 1, 2... for x-axis position
          int monthKey = entry.value; // The actual month 1-12
          double income = data[monthKey]?['income'] ?? 0;
          double expense = data[monthKey]?['expense'] ?? 0;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: income,
                gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Color(0xFF00C853),
                    Color(0xFF69F0AE),
                  ], // Green accent gradient
                ),
                width: 12,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
              BarChartRodData(
                toY: expense,
                gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Color(0xFFD50000),
                    Color(0xFFFF5252),
                  ], // Red accent gradient
                ),
                width: 12,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            ],
            barsSpace: 4, // Space between income and expense bars
          );
        }).toList(),
        maxY: maxY > 0 ? maxY : 100,
      ),
    );
  }
}
