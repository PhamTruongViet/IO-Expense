import 'package:flutter/material.dart';
import '/helper/database_helper.dart';
import '/utils/date_formatter.dart';
import '/utils/money_formatter.dart';
import 'dart:ui';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  _TransactionListScreenState createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _wallets = [];
  bool _isLoading = true;
  String _selectedWallet = 'All Wallets';
  double _totalBalance = 0.0;
  double _selectedWalletBalance = 0.0;
  bool _showPopupButtons = false;
  Offset _iconPosition = const Offset(0, 0); // Initial position
  int _transactionId = 0;

  @override
  void initState() {
    super.initState();
    _fetchWalletsAndTransactions();
  }

  Future<void> _fetchWalletsAndTransactions() async {
    final wallets = await _dbHelper.getWallets();
    final transactions = await _dbHelper.getTransactions();
    double totalBalance =
        wallets.fold(0.0, (sum, wallet) => sum + wallet['balance']);

    setState(() {
      _wallets = wallets;
      _transactions = transactions;
      _totalBalance = totalBalance;
      _selectedWalletBalance = _selectedWallet == 'All Wallets'
          ? totalBalance
          : wallets.firstWhere((wallet) =>
              wallet['id'].toString() == _selectedWallet)['balance'];
      _isLoading = false;
    });

    // print('Wallets and transactions fetched');
    // print('Total Balance: $_totalBalance');
    // print('Selected Wallet Balance: $_selectedWalletBalance');
  }

  Future<void> _fetchTransactionsByWallet(String walletId) async {
    setState(() {
      _isLoading = true;
    });

    List<Map<String, dynamic>> transactions;
    double selectedWalletBalance = 0.0;

    if (walletId == 'All Wallets') {
      transactions = await _dbHelper.getTransactions();
      selectedWalletBalance = _totalBalance;
    } else {
      transactions = await _dbHelper.getTransactionsByWallet(walletId);
      final selectedWallet =
          _wallets.firstWhere((wallet) => wallet['id'].toString() == walletId);
      selectedWalletBalance = selectedWallet['balance'];
    }

    setState(() {
      _transactions = transactions;
      _selectedWalletBalance = selectedWalletBalance;
      _isLoading = false;
    });

    print('Transactions fetched for wallet: $walletId');
    print('Selected Wallet Balance: $selectedWalletBalance');
  }

  void _showPopup(Offset position, int index) {
    setState(() {
      _transactionId = index;
      _iconPosition = position;
      _showPopupButtons = true;
    });
  }

  void _hidePopup() {
    setState(() {
      _showPopupButtons = false;
    });
  }

  void _showTransactionDetails(Map<String, dynamic> transaction) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.5), // Dim background
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext context, Animation animation,
          Animation secondaryAnimation) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Add padding around dialog
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'Transaction Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Details', transaction['details']),
                    _buildDetailRow(
                        'Amount', '${formatMoney(transaction['amount'])} đ'),
                    _buildDetailRow('Type', transaction['transactionType']),
                    _buildDetailRow('Category', transaction['category']),
                    _buildDetailRow('Subcategory', transaction['subcategory']),
                    _buildDetailRow(
                        'Date', DateFormatter.format(transaction['date'])),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction List'),
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Total Balance',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${formatMoney(_selectedWalletBalance)} đ',
                            style: const TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          DropdownButton<String>(
                            value: _selectedWallet,
                            alignment: Alignment.center,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedWallet = newValue!;
                              });
                              _fetchTransactionsByWallet(_selectedWallet);
                            },
                            borderRadius: BorderRadius.circular(12.0),
                            items: [
                              const DropdownMenuItem<String>(
                                alignment: Alignment.center,
                                value: 'All Wallets',
                                child: Text('All Wallets'),
                              ),
                              ..._wallets.map((wallet) {
                                return DropdownMenuItem<String>(
                                  alignment: Alignment.center,
                                  value: wallet['id'].toString(),
                                  child: Text(wallet['name']),
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _transactions.isEmpty
                          ? const Center(
                              child: Text(
                                'There is no transaction yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black54,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _transactions.length,
                              itemBuilder: (context, index) {
                                final transaction = _transactions[index];

                                return GestureDetector(
                                  onTap: () {
                                    _showTransactionDetails(transaction);
                                  },
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(8.0),
                                    subtitle: Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text:
                                                '${formatMoney(transaction['amount'])} đ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: transaction[
                                                          'transactionType'] ==
                                                      'Income'
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                '\n${DateFormatter.format(transaction['date'])}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.normal,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(transaction['category']),
                                        const SizedBox(width: 8.0),
                                        GestureDetector(
                                          onTapDown: (details) {
                                            _showPopup(details.globalPosition,
                                                transaction['id']);
                                          },
                                          child: const Icon(Icons.more_vert),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
          if (_showPopupButtons)
            Positioned.fill(
              child: GestureDetector(
                onTap: _hidePopup,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            left: _showPopupButtons
                ? _iconPosition.dx - 110.0
                : _iconPosition.dx + 20,
            top: _showPopupButtons
                ? _iconPosition.dy - 150.0
                : _iconPosition.dy - 150.0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _showPopupButtons ? 1.0 : 0.0,
              child: Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      _hidePopup();
                      await _dbHelper.deleteTransaction(_transactionId);
                      await _fetchWalletsAndTransactions();
                    },
                  ),
                  const SizedBox(height: 8.0),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      _hidePopup();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
