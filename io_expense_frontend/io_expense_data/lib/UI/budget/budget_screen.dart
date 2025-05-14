import 'package:flutter/material.dart';
import 'add_budget_screen.dart';
import 'progress_calculator.dart';
import '/helper/database_helper.dart';
import '/../utils/money_formatter.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  BudgetScreenState createState() => BudgetScreenState();
}

class BudgetScreenState extends State<BudgetScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Map<String, dynamic>> _wallets = [];
  final Map<String, double> _progressCategory = {};
  final Map<String, double> _progressWallet = {};
  final Map<String, double> _totalSpentWallet = {};
  final Map<String, double> _totalBudgetOnWallet = {};
  final Map<String, double> _totalSpentBudget = {};
  final List<String> _daysRemain = [];
  final BudgetProgressCalculator calculateProgress = BudgetProgressCalculator();

  Future<void> _fetchWalletsWithBudgets() async {
    final budgets = await _databaseHelper.getAllBudgets();
    final walletIds =
        budgets.map((budget) => budget['walletId'].toString()).toSet().toList();

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

    await _fetchProgressData(walletIds);

    setState(() {
      _wallets = wallets;
    });
  }

  Future<void> _fetchProgressData(List<String> walletIds) async {
    _totalSpentBudget.clear();
    _progressCategory.clear();
    _progressWallet.clear();
    _totalSpentWallet.clear();
    _totalBudgetOnWallet.clear();
    _daysRemain.clear();

    for (var walletId in walletIds) {
      final walletProgress =
          await calculateProgress.calculateWalletProgress(walletId);
      final categoryProgress =
          await calculateProgress.getBudgetsProgress(walletId);
      _progressWallet[walletId] = walletProgress;
      _progressCategory.addAll(categoryProgress);
      _totalSpentWallet[walletId] =
          await calculateProgress.calculateTotalWalletBase(walletId);
      final totalBudgetSpent =
          await calculateProgress.getCurrentSpentOnEachBudget(walletId);
      _totalSpentBudget.addAll(totalBudgetSpent);
      _totalBudgetOnWallet[walletId] =
          await calculateProgress.getTotalBudgetAmount(walletId);
      final daysRemaining = await calculateProgress.getDaysRemaining(walletId);
      _daysRemain.addAll(daysRemaining);
    }
  }

  Animation<Color> getProgressColor(double progress) {
    if (progress > 0.7) {
      return const AlwaysStoppedAnimation<Color>(Colors.red);
    } else if (progress > 0.5) {
      return const AlwaysStoppedAnimation<Color>(
          Color.fromARGB(255, 230, 213, 54));
    } else {
      return const AlwaysStoppedAnimation<Color>(Colors.green);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWalletsWithBudgets().then((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddBudgetScreen()),
                    ).then((_) {
                      _fetchWalletsWithBudgets();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 54, 54, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Add Budget',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _wallets.isEmpty
                    ? const Center(
                        child: Text(
                          'There is no budget yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black54,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _wallets.length,
                        itemBuilder: (context, index) {
                          final wallet = _wallets[index];
                          final walletId = wallet['id'].toString();
                          return Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ExpansionTile(
                              initiallyExpanded: true,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              tilePadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              title: Text(wallet['name'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Text(
                                      'Total Budget: ${formatMoney(_totalBudgetOnWallet[walletId]!.toDouble())} đ'),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: _progressWallet[walletId] ?? 0.0,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: getProgressColor(
                                        _progressWallet[walletId] ?? 0.0),
                                    minHeight: 12,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ],
                              ),
                              children: wallet['budgets'].map<Widget>((budget) {
                                final progress =
                                    _progressCategory[budget['category']] ??
                                        0.0;
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  title: Text(budget['category']),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 6),
                                      Text(
                                          'Spent: ${formatMoney(_totalSpentBudget[budget['category']]!.toDouble())} / ${formatMoney(budget['amount'])} đ'),
                                      const SizedBox(height: 4),
                                      LinearProgressIndicator(
                                        value: progress,
                                        backgroundColor: Colors.grey[300],
                                        valueColor: getProgressColor(progress),
                                        minHeight: 7,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ],
                                  ),
                                  trailing: Text(
                                    '${(_daysRemain[index])} days',
                                    style: TextStyle(
                                      color: _daysRemain[index] == '0'
                                          ? Colors.red
                                          : Colors.black,
                                    ),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
