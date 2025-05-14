import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

List<BarChartGroupData> getColumnChartSections(
    List<Map<String, dynamic>> transactions) {
  final Map<int, double> monthlyExpenses = {};
  final Map<int, double> monthlyIncomes = {};

  for (var transaction in transactions) {
    final date = DateTime.parse(transaction['date']);
    final amount = transaction['amount'] as double;
    final type = transaction['transactionType'] as String;

    if (type == 'Expense') {
      monthlyExpenses[date.month] = (monthlyExpenses[date.month] ?? 0) + amount;
    } else if (type == 'Income') {
      monthlyIncomes[date.month] = (monthlyIncomes[date.month] ?? 0) + amount;
    }
  }

  final List<BarChartGroupData> barGroups = [];
  for (int i = 1; i <= 12; i++) {
    barGroups.add(
      BarChartGroupData(
        x: i,
        barsSpace: 0,
        barRods: [
          BarChartRodData(
            toY: monthlyExpenses[i] ?? 0,
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 236, 52, 52),
                Color.fromARGB(255, 233, 137, 137)
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: 8,
            borderRadius: BorderRadius.circular(2),
          ),
          BarChartRodData(
            toY: monthlyIncomes[i] ?? 0,
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 47, 227, 47),
                Color.fromARGB(255, 140, 219, 140)
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: 8,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }

  return barGroups;
}
