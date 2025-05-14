import 'package:flutter/material.dart';
import 'package:io_expense_data/services/api_service.dart';

class AddWalletScreen extends StatefulWidget {
  const AddWalletScreen({super.key});

  @override
  _AddWalletScreenState createState() => _AddWalletScreenState();
}

class _AddWalletScreenState extends State<AddWalletScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _walletNameController = TextEditingController();
  final TextEditingController _walletBalanceController =
      TextEditingController();

  void _addWallet() async {
    final walletName = _walletNameController.text;
    final walletBalance = _walletBalanceController.text;

    if (walletName.isNotEmpty && walletBalance.isNotEmpty) {
      final wallet = {
        'name': walletName,
        'balance': walletBalance,
        'date': DateTime.now().toIso8601String(),
      };

      await _apiService.addWallet(wallet);
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Wallet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _walletNameController,
              decoration: const InputDecoration(
                labelText: 'Wallet Name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _walletBalanceController,
              decoration: const InputDecoration(
                labelText: 'Wallet Balance',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addWallet,
              child: const Text('Add Wallet'),
            ),
          ],
        ),
      ),
    );
  }
}
