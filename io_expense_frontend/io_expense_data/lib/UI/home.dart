import 'package:flutter/material.dart';
import 'package:io_expense_data/UI/report.dart';
import 'package:io_expense_data/UI/transaction/transaction_list.dart';
import 'package:io_expense_data/components/bottom_navigation_bar.dart';
import 'package:io_expense_data/UI/transaction/transaction_input_screen.dart';
import 'package:io_expense_data/UI/auth/logout_screen.dart';
import 'package:io_expense_data/UI/budget/budget_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onItemTapped(int index) {
    if ((index - _currentIndex).abs() == 1) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _pageController.jumpToPage(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          const TransactionListScreen(),
          const BudgetScreen(),
          const TransactionInputScreen(),
          const ReportScreen(),
          LogoutScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBarComponent(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
