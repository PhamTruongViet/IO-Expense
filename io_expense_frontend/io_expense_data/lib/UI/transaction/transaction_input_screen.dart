import 'package:flutter/material.dart';
import 'package:io_expense_data/components/custom_numpad.dart';
import 'package:io_expense_data/services/api_service.dart';
import 'package:io_expense_data/helper/database_helper.dart';
import 'package:io_expense_data/models/transaction_data.dart';
import 'package:io_expense_data/UI/categories/category_selection_screen.dart';
import 'package:io_expense_data/UI/widgets/wallet_selection.dart';
import 'package:io_expense_data/UI/transaction/attachments_screen.dart';
import 'package:io_expense_data/UI/transaction/detail_input_screen.dart';
import 'package:io_expense_data/components/date_picker_button.dart';

class TransactionInputScreen extends StatefulWidget {
  const TransactionInputScreen({super.key});

  @override
  _TransactionInputScreenState createState() => _TransactionInputScreenState();
}

class _TransactionInputScreenState extends State<TransactionInputScreen> {
  final ApiService _apiService = ApiService();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  double amount = 0;
  String _selectedTransactionType = 'Select Transaction Type';
  String _selectedCategory = 'Select Category';
  String _selectedSubcategory = 'Select Category';
  String _selectedWallet = 'Select Wallet';
  String _walletId = '0';
  String _filePath = '';
  String _details = '';

  bool _isNumpadVisible = false;
  DateTime? _selectedDate;

  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  void _hideNumpad() {
    setState(() {
      _isNumpadVisible = false;
    });
  }

  double getAmount() {
    return double.parse(_amountController.text);
  }

  transaction_data _gatherExpenseData() {
    return transaction_data(
      amount: getAmount(),
      details: _details,
      transactionType: _selectedTransactionType,
      category: _selectedCategory,
      subcategory: _selectedSubcategory,
      walletId: _walletId,
      filePath: _filePath,
      date: _selectedDate,
    );
  }

  bool _isTransactionDataSufficient() {
    return _amountController.text.isNotEmpty &&
        _selectedTransactionType != 'Select Transaction Type' &&
        _selectedCategory != 'Select Category' &&
        _selectedWallet != 'Select Wallet' &&
        _selectedDate != null;
  }

  Future<void> _saveTransaction() async {
    final transaction = _gatherExpenseData();
    try {
      await _apiService.addTransaction(transaction);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            ListView(
              padding: const EdgeInsets.all(16.0),
              children: <Widget>[
                const SizedBox(height: 16.0),
                const Text(
                  'Amount',
                  style: TextStyle(fontSize: 16.0, color: Colors.black54),
                ),
                const SizedBox(height: 8.0),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isNumpadVisible = true;
                    });
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        hintText: 'Enter amount',
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 16.0),
                      ),
                      style: const TextStyle(fontSize: 18.0),
                      readOnly: true,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final selectedData = await Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const CategorySelectionScreen(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                            ),
                          );
                          if (selectedData != null) {
                            setState(() {
                              _selectedTransactionType =
                                  selectedData['transactionType'];
                              _selectedCategory = selectedData['category'];
                              _selectedSubcategory =
                                  selectedData['subcategory'];
                            });
                            final mostUsedWallet =
                                await _dbHelper.getMostUsedWalletByTransaction(
                                    _selectedCategory);
                            if (mostUsedWallet != null) {
                              setState(() {
                                _selectedWallet = mostUsedWallet['name'];
                                _walletId = mostUsedWallet['id'].toString();
                              });
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 16.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  overflow: TextOverflow.ellipsis,
                                  _selectedSubcategory == ''
                                      ? _selectedCategory
                                      : _selectedSubcategory,
                                  style: const TextStyle(fontSize: 16.0),
                                ),
                              ),
                              const Icon(Icons.arrow_forward),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                        width: 16.0), // Add spacing between the two buttons
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final selectedData = await Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const WalletSelectionScreen(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                            ),
                          );
                          if (selectedData != null) {
                            setState(() {
                              _selectedWallet = selectedData.name;
                              _walletId = selectedData.id.toString();
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 16.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  overflow: TextOverflow.ellipsis,
                                  _selectedWallet,
                                  style: const TextStyle(
                                      fontSize: 17.0, color: Colors.black54),
                                ),
                              ),
                              const Icon(Icons.arrow_forward),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                DatePickerButton(
                  onDateSelected: (date) {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                OutlinedButton.icon(
                  onPressed: () async {
                    final String? selectedData = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailInputScreen(),
                      ),
                    );
                    if (selectedData != null) {
                      setState(() {
                        _details = selectedData;
                      });
                    }
                  },
                  icon: const Icon(Icons.description, color: Colors.black54),
                  label: const Text('Details'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
                Text(
                  'Details: $_details',
                  style: const TextStyle(fontSize: 16.0, color: Colors.black54),
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            AttachmentScreen(path: _filePath),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                      ),
                    );
                    if (result != null) {
                      setState(() {
                        _filePath = result as String;
                      });
                    }
                  },
                  icon: const Icon(Icons.attachment, color: Colors.black54),
                  label: const Text('Attachment'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
                if (_filePath != '')
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      'File Path: $_filePath',
                      style: const TextStyle(
                          fontSize: 16.0, color: Colors.black54),
                    ),
                  ),
              ],
            ),
            if (!_isNumpadVisible)
              Positioned(
                bottom: 20.0,
                left: 16.0,
                right: 16.0,
                child: ElevatedButton(
                  onPressed: _isTransactionDataSufficient()
                      ? () => _saveTransaction()
                      : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: _isTransactionDataSufficient()
                        ? Colors.greenAccent
                        : Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text('Save'),
                ),
              ),
            if (_isNumpadVisible)
              CustomNumpad(
                amountController: _amountController,
                onEnterPressed: _hideNumpad,
              ),
          ],
        ),
      ),
    );
  }
}
