import 'package:fl_chart/fl_chart.dart';
import 'package:io_expense_data/models/pie_chart_data.dart';
import 'package:flutter/material.dart';

List<PieChartSectionData> getSections(List<DataPieChart> data,
    {int touchedIndex = -1}) {
  return data
      .asMap()
      .map<int, PieChartSectionData>((index, data) {
        final isTouched = index == touchedIndex;
        final double fontSize = isTouched ? 25 : 16;
        final double radius = isTouched ? 100 : 80;
        String percentage = '${data.percent.toStringAsFixed(1)}%';

        final value = PieChartSectionData(
          color: data.color,
          value: data.percent,
          title: percentage,
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: const Color(0xffffffff),
            shadows: const <Shadow>[
              Shadow(
                blurRadius: 2,
                color: Color.fromARGB(255, 53, 46, 1),
                offset: Offset(1, 1),
              ),
            ],
          ),
        );

        return MapEntry(index, value);
      })
      .values
      .toList();
}
