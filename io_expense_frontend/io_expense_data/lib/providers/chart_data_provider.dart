import 'package:flutter/material.dart';
import 'package:io_expense_data/helper/database_helper.dart';
import 'package:io_expense_data/models/pie_chart_data.dart';
import 'package:io_expense_data/models/line_chart_data.dart';
import 'package:io_expense_data/UI/widgets/column_chart_sections.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartDataProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<DataPieChart> _pieChartData = [];
  List<List<FlSpot>> _lineChartData = [[], []];
  List<BarChartGroupData> _columnChartData = [];
  bool _isLoading = true;
  String _selectedLineChart = 'week';

  String get selectedLineChart => _selectedLineChart;
  List<DataPieChart> get pieChartData => _pieChartData;
  List<List<FlSpot>> get lineChartData => _lineChartData;
  List<BarChartGroupData> get columnChartData => _columnChartData;
  bool get isLoading => _isLoading;

  Future<void> fetchData() async {
    _isLoading = true;
    notifyListeners();

    final transactionsMonth = await _dbHelper.getTransactionsForCurrentMonth();
    final transactionsWeek = await _dbHelper.getTransactionsForCurrentWeek();
    final transactionsYear = await _dbHelper.getTransactionsForCurrentYear();
    final totals = calculateTotalAmountsByCategory(transactionsMonth);
    final pieChartData = preparePieChartData(totals);
    final lineChartDataWeek = prepareLineChartData(transactionsWeek, 'week');
    final lineChartDataMonth = prepareLineChartData(transactionsMonth, 'month');
    final columnChartData = getColumnChartSections(transactionsYear);

    _pieChartData = pieChartData;
    _lineChartData = lineChartDataWeek;
    _columnChartData = columnChartData;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchLineChartDataByPeriod(String period) async {
    _isLoading = true;
    _selectedLineChart = period;
    notifyListeners();

    final transactionsMonth = await _dbHelper.getTransactionsForCurrentMonth();
    final transactionsWeek = await _dbHelper.getTransactionsForCurrentWeek();

    if (period == 'week') {
      _lineChartData = prepareLineChartData(transactionsWeek, 'week');
    } else if (period == 'month') {
      _lineChartData = prepareLineChartData(transactionsMonth, 'month');
    }

    _isLoading = false;
    notifyListeners();
  }
}
