import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

List<LineChartBarData> getLineChartSections(
    List<FlSpot> inflowData, List<FlSpot> outflowData) {
  return [
    LineChartBarData(
      spots: inflowData,
      isCurved: true,
      curveSmoothness: 0.5,
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color.fromARGB(255, 85, 135, 87),
          const Color.fromARGB(255, 85, 135, 87).withOpacity(0.2),
        ],
      ),
      preventCurveOverShooting: true,
      barWidth: 4,
      isStrokeCapRound: true,
      dotData: FlDotData(
          show: true,
          checkToShowDot: (spot, barData) {
            return spot.y != 0;
          }),
      belowBarData: BarAreaData(
        show: true,
        color: const Color.fromARGB(255, 85, 135, 87).withOpacity(0.2),
      ),
    ),
    LineChartBarData(
      spots: outflowData,
      isCurved: true,
      curveSmoothness: 0.5,
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color.fromARGB(255, 212, 64, 53),
          const Color.fromARGB(255, 212, 64, 53).withOpacity(0.2),
        ],
      ),
      preventCurveOverShooting: true,
      barWidth: 4,
      isStrokeCapRound: false,
      dotData: FlDotData(
          show: true,
          checkToShowDot: (spot, barData) {
            return spot.y != 0;
          }),
      belowBarData: BarAreaData(
        show: true,
        color: const Color.fromARGB(255, 212, 64, 53).withOpacity(0.2),
      ),
    ),
  ];
}
