import 'package:flutter/material.dart';
import 'package:io_expense_data/services/auth_service.dart';
import 'package:io_expense_data/main.dart';
import 'package:io_expense_data/helper/database_helper.dart';
import 'package:io_expense_data/UI/wallet/wallet_list.dart';

class LogoutScreen extends StatelessWidget {
  final AuthService _authService = AuthService();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  LogoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  await _dbHelper.deleteDatabaseFile();
                  await _authService.logout();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const MyApp()),
                    (Route<dynamic> route) => false,
                  );
                },
                child: const Text('Đăng xuất'),
              ),
            )
          ],
        ),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => const WalletScreen()),
                  );
                },
                child: const Text('Quản lý ví'),
              ),
            )
          ],
        )
      ])),
    );
  }
}
