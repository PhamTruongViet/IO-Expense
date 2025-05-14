import 'package:fl_chart/fl_chart.dart';

List<List<FlSpot>> prepareLineChartData(
    List<Map<String, dynamic>> transactions, String period) {
  final Map<int, double> inflow = {};
  final Map<int, double> outflow = {};

  for (var transaction in transactions) {
    final date = DateTime.parse(transaction['date']);
    final int key;
    if (period == 'week') {
      key = date.weekday;
    } else if (period == 'month') {
      key = date.day;
    } else {
      throw ArgumentError('Invalid period: $period');
    }
    final amount = transaction['amount'] as double;
    final type = transaction['transactionType'] as String;

    if (type == 'Income') {
      inflow[key] = (inflow[key] ?? 0) + amount;
    } else if (type == 'Expense') {
      outflow[key] = (outflow[key] ?? 0) + amount;
    }
  }

  final List<FlSpot> inflowSpots = [];
  final List<FlSpot> outflowSpots = [];

  final int daysInPeriod = period == 'week' ? 7 : DateTime.now().day;

  for (int i = 1; i <= daysInPeriod; i++) {
    inflowSpots.add(FlSpot(i.toDouble(), inflow[i] ?? 0));
    outflowSpots.add(FlSpot(i.toDouble(), outflow[i] ?? 0));
  }

  return [inflowSpots, outflowSpots];
}
