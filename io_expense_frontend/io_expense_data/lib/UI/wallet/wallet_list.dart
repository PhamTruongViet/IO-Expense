import 'package:flutter/material.dart';
import 'package:io_expense_data/helper/database_helper.dart';
import 'add_wallets.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<WalletModel> _wallets = [];
  bool _haveNoWallet = true;

  @override
  void initState() {
    super.initState();
    _fetchWallet();
  }

  Future<void> _fetchWallet() async {
    final List<Map<String, dynamic>> wallets = await _dbHelper.getWallets();
    print(wallets);
    setState(() {
      _wallets = wallets.map((wallet) => WalletModel.fromMap(wallet)).toList();
      _haveNoWallet = _wallets.isEmpty;
    });
    for (var i = 0; i < wallets.length; i++) {
      _listKey.currentState?.insertItem(i);
    }
  }

  void _addWallet(WalletModel wallet) {
    setState(() {
      _wallets.add(wallet);
      _haveNoWallet = _wallets.isEmpty;
    });
    _listKey.currentState?.insertItem(_wallets.length - 1);
  }

  void _deleteWallet(int id) {
    setState(() {
      final index = _wallets.indexWhere((wallet) => wallet.id == id);
      var wallet = _wallets.removeAt(index);
      _listKey.currentState!.removeItem(
        index,
        (context, animation) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: const Interval(0.2, 0.5),
            ),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0), // Slide in from the right
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: const Interval(0.0, 0.5),
              )),
              child: _buildItem(wallet),
            ),
          );
        },
        duration: const Duration(milliseconds: 600),
      );
      _dbHelper.deleteWallet(id);
    });
  }

  Widget _buildItem(WalletModel wallet) {
    return ListTile(
      key: ValueKey<WalletModel>(wallet),
      title: Text(wallet.name),
      subtitle: Text('\$${wallet.balance}'),
      leading: const CircleAvatar(
        child: Icon(Icons.account_balance_wallet),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () => _deleteWallet(wallet.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallets', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () async {
              final result = await Navigator.of(context).push(
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
              );
              if (result == true) {
                final newWallet = await _dbHelper.getLatestWallet();
                _addWallet(WalletModel.fromMap(newWallet));
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _haveNoWallet
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'No Wallets',
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const AddWalletScreen(),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        );
                        if (result == true) {
                          _fetchWallet();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: const Text(
                        'Add Wallet',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              )
            : AnimatedList(
                key: _listKey,
                initialItemCount: _wallets.length,
                itemBuilder: (context, index, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: _buildItem(_wallets[index]),
                  );
                },
              ),
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
