import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:io_expense_data/UI/widgets/indicator_pie_chart_widget.dart';
import 'package:io_expense_data/UI/widgets/pie_chart_sections.dart';
import 'package:io_expense_data/UI/widgets/line_chart_sections.dart';
import 'package:io_expense_data/providers/chart_data_provider.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<ChartDataProvider>(context, listen: false).fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff2c4260),
      body: Consumer<ChartDataProvider>(
        builder: (context, chartDataProvider, child) {
          if (chartDataProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 40),
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Monthly Expenses',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AspectRatio(
                        aspectRatio: 1.3,
                        child: PieChart(
                          PieChartData(
                            sections: getSections(chartDataProvider.pieChartData),
                            borderData: FlBorderData(show: false),
                            sectionsSpace: 0,
                            centerSpaceRadius: 40,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      IndicatorPieChartWidget(data: chartDataProvider.pieChartData),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      DropdownButton<String>(
                        value: chartDataProvider.selectedLineChart,
                        onChanged: (String? newValue) {
                          chartDataProvider.fetchLineChartDataByPeriod(newValue!);
                        },
                        items: const [
                          DropdownMenuItem<String>(
                            value: 'Week Flow',
                            child: Text('Week Flow'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'Month Flow',
                            child: Text('Month Flow'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AspectRatio(
                        aspectRatio: 1.5,
                        child: LineChart(
                          LineChartData(
                            lineBarsData: getLineChartSections(chartDataProvider.lineChartData[0],
                                chartDataProvider.lineChartData[1]),
                            titlesData: FlTitlesData(
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: false,
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 1,
                                  getTitlesWidget: (value, meta) {
                                    final intValue = value.toInt();
                                    if (chartDataProvider.selectedLineChart == 'Week Flow') {
                                      switch (intValue) {
                                        case 1:
                                          return const Text('Mon');
                                        case 2:
                                          return const Text('Tue');
                                        case 3:
                                          return const Text('Wed');
                                        case 4:
                                          return const Text('Thu');
                                        case 5:
                                          return const Text('Fri');
                                        case 6:
                                          return const Text('Sat');
                                        case 7:
                                          return const Text('Sun');
                                      }
                                    } else if (chartDataProvider.selectedLineChart ==
                                        'Month Flow') {
                                      if (intValue % 5 == 0 || intValue == 1) {
                                        return Text(intValue.toString());
                                      }
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            gridData: const FlGridData(show: false),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Monthly Flow',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AspectRatio(
                        aspectRatio: 1.5,
                        child: BarChart(
                          BarChartData(
                            barGroups: chartDataProvider.columnChartData,
                            titlesData: const FlTitlesData(
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: bottomTitles,
                                  reservedSize: 42,
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: false,
                                ),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: false,
                            ),
                            gridData: const FlGridData(show: false),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

Widget bottomTitles(double value, TitleMeta meta) {
  final titles = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  final Widget text = Text(
    titles[(value.toInt() - 1) % 12],
    style: const TextStyle(
      color: Color(0xff7589a2),
      fontWeight: FontWeight.bold,
      fontSize: 13,
    ),
  );

  return SideTitleWidget(
    axisSide: meta.axisSide,
    space: 17,
    child: text,
  );
}
