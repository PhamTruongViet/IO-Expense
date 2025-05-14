import 'package:io_expense_data/helper/database_helper.dart';
import 'package:io_expense_data/models/budget_data.dart';

class BudgetProgressCalculator {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<List<Map<String, dynamic>>> _getBudgetTransactions(
      budget_data budget) async {
    final transactions =
        await _databaseHelper.getTransactionsByWallet(budget.walletId!);
    return transactions.where((transaction) {
      final transactionDate = DateTime.parse(transaction['date']);
      return transaction['category'] == budget.category &&
          transactionDate.isAfter(budget.startDate!) &&
          transactionDate.isBefore(budget.endDate!);
    }).toList();
  }

  double _calculateTotalSpent(List<Map<String, dynamic>> transactions) {
    return transactions.fold(
        0.0, (sum, transaction) => sum + transaction['amount']);
  }

  Future<double> calculateCategoryProgress(budget_data budget) async {
    final budgetTransactions = await _getBudgetTransactions(budget);
    final totalSpent = _calculateTotalSpent(budgetTransactions);

    double result = totalSpent / budget.amount;
    if (result > 1) return 1;
    return result;
  }

  Future<double> calculateWalletProgress(String walletId) async {
    final transactions =
        await _databaseHelper.getTransactionsByWallet(walletId);
    final budgets = await _databaseHelper.getBudgetsByWallet(walletId);

    double totalBudget = 0.0;
    double totalSpent = 0.0;

    for (var budgetMap in budgets) {
      final budget = budget_data.fromMap(budgetMap);
      final budgetTransactions = transactions.where((transaction) {
        final transactionDate = DateTime.parse(transaction['date']);
        return transaction['category'] == budget.category &&
            transactionDate.isAfter(budget.startDate!) &&
            transactionDate.isBefore(budget.endDate!);
      }).toList();

      totalBudget += budget.amount;
      totalSpent += _calculateTotalSpent(budgetTransactions);
    }
    double result = totalSpent / totalBudget;
    if (result > 1) return 1;
    return result;
  }

  Future<double> calculateTotalWalletBase(String walletId) async {
    final transactions =
        await _databaseHelper.getTransactionsByWallet(walletId);
    return _calculateTotalSpent(transactions);
  }

  Future<double> getTotalBudgetAmount(String walletId) async {
    final budgets = await _databaseHelper.getBudgetsByWallet(walletId);
    final total = budgets.fold(0.0, (sum, budget) => sum + budget['amount']);
    return total;
  }

  Future<Map<String, double>> getCurrentSpentOnEachBudget(
      String walletId) async {
    final budgets = await _databaseHelper.getBudgetsByWallet(walletId);
    final Map<String, double> spentMap = {};

    for (var budgetMap in budgets) {
      final budget = budget_data.fromMap(budgetMap);
      final budgetTransactions = await _getBudgetTransactions(budget);
      final totalSpent = _calculateTotalSpent(budgetTransactions);
      spentMap[budget.category] = totalSpent;
    }

    return spentMap;
  }

  Future<Map<String, double>> getBudgetsProgress(String walletId) async {
    final budgets = await _databaseHelper.getBudgetsByWallet(walletId);
    final Map<String, double> progressMap = {};

    for (var budgetMap in budgets) {
      final budget = budget_data.fromMap(budgetMap);
      final progress = await calculateCategoryProgress(budget);
      progressMap[budget.category] = progress;
    }

    return progressMap;
  }

  Future<List<String>> getDaysRemaining(String walletId) async {
    final budgets = await _databaseHelper.getBudgetsByWallet(walletId);
    final List<String> daysRemain = [];

    for (var budgetMap in budgets) {
      final budget = budget_data.fromMap(budgetMap);
      final days = budget.endDate!.difference(DateTime.now()).inDays;
      if (days > 0) {
        daysRemain.add(days.toString());
      } else {
        daysRemain.add('0');
      }
    }

    return daysRemain;
  }
}
