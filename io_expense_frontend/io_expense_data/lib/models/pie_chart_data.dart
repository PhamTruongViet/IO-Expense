import 'dart:math';

import 'package:flutter/material.dart';

Map<String, double> calculateTotalAmountsByCategory(List<Map<String, dynamic>> transactions) {
  final Map<String, double> totals = {};

  for (var transaction in transactions) {
    if (transaction['transactionType'] != 'Expense') {
      continue;
    }

    final category = transaction['category'] as String;
    final amount = transaction['amount'] as double;

    if (totals.containsKey(category)) {
      totals[category] = totals[category]! + amount;
    } else {
      totals[category] = amount;
    }
  }

  return totals;
}

List<DataPieChart> preparePieChartData(Map<String, double> totals) {
  final List<DataPieChart> data = [];
  var totalSpent = 0.0;
  // Calculate the total amount spent
  totals.forEach((category, amount) {
    totalSpent += amount;
  });

  totals.forEach((category, amount) {
    if ((amount / totalSpent) * 100 > 0.1) {
      data.add(
        DataPieChart(
          name: category,
          percent: (amount / totalSpent) * 100,
          color: getColorForCategory(category),
        ),
      );
    }
  });

  return data;
}

Color getColorForCategory(String category) {
  // Define a color mapping for categories
  switch (category) {
    case 'Food':
      return const Color.fromARGB(255, 246, 109, 68);
    case 'Transport':
      return const Color.fromARGB(255, 254, 174, 101);
    case 'Entertainment':
      return const Color.fromARGB(255, 230, 246, 157);
    case 'Healthcare':
      return const Color.fromARGB(255, 170, 222, 167);
    case 'Shopping':
      return const Color.fromARGB(255, 100, 194, 166);
    case 'Bills':
      return const Color.fromARGB(255, 233, 30, 98);
    case 'Education':
      return const Color.fromARGB(255, 45, 135, 187);
    case 'Rental':
      return const Color.fromARGB(255, 76, 175, 79);
    case 'Others':
      return const Color.fromARGB(255, 255, 235, 59);
    default:
      return getRandomColor();
  }
}

Color getRandomColor() {
  final Random random = Random();
  return Color.fromARGB(255, random.nextInt(256), random.nextInt(256), random.nextInt(256));
}

class DataPieChart {
  final String name;
  final double percent;
  final Color color;

  DataPieChart({required this.name, required this.percent, required this.color});
}
