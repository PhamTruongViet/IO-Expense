import 'package:flutter/material.dart';
import 'package:io_expense_data/helper/database_helper.dart';
import 'package:io_expense_data/UI/wallet/add_wallets.dart';

class WalletSelectionScreen extends StatefulWidget {
  const WalletSelectionScreen({super.key});

  @override
  _WalletSelectionScreenState createState() => _WalletSelectionScreenState();
}

class _WalletSelectionScreenState extends State<WalletSelectionScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<WalletModel> _wallets = [];

  @override
  void initState() {
    super.initState();
    _fetchWallets();
  }

  Future<void> _fetchWallets() async {
    final List<Map<String, dynamic>> wallets = await _dbHelper.getWallets();
    setState(() {
      _wallets = wallets.map((wallet) => WalletModel.fromMap(wallet)).toList();
    });
  }

  void _selectWallet(WalletModel wallet) {
    Navigator.of(context).pop(wallet);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Wallet'),
      ),
      body: _wallets.isEmpty
          ? Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const AddWalletScreen(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                    ),
                  ).then((_) {
                    _fetchWallets(); // Refresh the wallet list when returning
                  });
                },
                child: const Text(
                  'No wallets found. Add a wallet to continue.',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            )
          : ListView.builder(
              itemCount: _wallets.length,
              itemBuilder: (context, index) {
                final wallet = _wallets[index];
                return ListTile(
                  title: Text(wallet.name),
                  subtitle: Text('\$${wallet.balance}'),
                  onTap: () => _selectWallet(wallet),
                );
              },
            ),
    );
  }
}

class WalletModel {
  WalletModel(this.id, this.name, this.balance);

  final int id;
  final String name;
  final double balance;

  factory WalletModel.fromMap(Map<String, dynamic> map) {
    return WalletModel(
      map['id'] as int,
      map['name'] as String,
      map['balance'] as double,
    );
  }
}
