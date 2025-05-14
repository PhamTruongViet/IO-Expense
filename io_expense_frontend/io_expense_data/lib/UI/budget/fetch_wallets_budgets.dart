import 'package:flutter/material.dart';
import 'package:io_expense_data/helper/database_helper.dart';
import 'progress_calculator.dart';
import 'package:io_expense_data/models/budget_data.dart';

class WalletsWithBudgets extends StatefulWidget {
  const WalletsWithBudgets({super.key});

  @override
  _WalletsWithBudgetsState createState() => _WalletsWithBudgetsState();
}

class _WalletsWithBudgetsState extends State<WalletsWithBudgets> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Map<String, dynamic>> _wallets = [];
  final List<Map<String, dynamic>> _progress = [];

  final BudgetProgressCalculator calculateProgress = BudgetProgressCalculator();
  @override
  void initState() {
    super.initState();
    _fetchWalletsWithBudgets();
  }

  Future<void> _fetchWalletsWithBudgets() async {
    final budgets = await _databaseHelper.getAllBudgets();
    final walletIds =
        budgets.map((budget) => budget['walletId']).toSet().toList();

    List<Map<String, dynamic>> wallets = [];
    for (var walletId in walletIds) {
      final wallet = await _databaseHelper.getWalletById(int.parse(walletId));
      if (wallet != null) {
        final mutableWallet = Map<String, dynamic>.from(wallet);
        mutableWallet['budgets'] =
            budgets.where((budget) => budget['walletId'] == walletId).toList();
        wallets.add(mutableWallet);
      }
    }

    for (var wallet in wallets) {
      for (var budgetMap in wallet['budgets']) {
        final budget = budget_data.fromMap(budgetMap);
        final progress =
            await calculateProgress.calculateCategoryProgress(budget);
        _progress.add({'category': budget.category, 'progress': progress});
      }
    }

    setState(() {
      _wallets = wallets;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Wallets with Budgets'),
      // ),
      body: ListView.builder(
        itemCount: _wallets.length,
        itemBuilder: (context, index) {
          final wallet = _wallets[index];
          return ExpansionTile(
            initiallyExpanded: true,
            title: Text(wallet['name']),
            subtitle: Text('Balance: ${wallet['balance']}'),
            children: wallet['budgets'].map<Widget>((budget) {
              final progress = _progress.firstWhere((element) =>
                  element['category'] == budget['category'])['progress'];
              return ListTile(
                title: Text('${budget['category']}'),
                subtitle: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
