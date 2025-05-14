import 'package:flutter/material.dart';
import 'package:io_expense_data/helper/database_helper.dart';
import 'package:io_expense_data/UI/widgets/wallet_selection.dart';
import 'package:io_expense_data/models/budget_data.dart';
import '../../components/custom_numpad.dart';
import '../../services/api_service.dart';
import '../categories/category_selection_screen.dart';
import '../../components/date_picker_button.dart';

class AddBudgetScreen extends StatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  _AddBudgetScreenState createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final ApiService _apiService = ApiService();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  double amount = 0;
  String _selectedTransactionType = 'Select Transaction Type';
  String _selectedCategory = 'Select Category';
  String _selectedSubcategory = 'Select Category';
  String _selectedWallet = 'Select Wallet';
  String _walletId = '0';
  final String _details = '';
  final int _isRepeat = 0;

  bool _isNumpadVisible = false;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedStartDate = DateTime.parse('2024-10-01');
    _selectedEndDate = DateTime.parse('2024-10-31');
  }

  void _hideNumpad() {
    setState(() {
      _isNumpadVisible = false;
    });
  }

  double getAmount() {
    return double.parse(_amountController.text);
  }

  budget_data _gatherBudgetData() {
    return budget_data(
      amount: getAmount(),
      details: _details,
      category: _selectedCategory,
      walletId: _walletId,
      startDate: _selectedStartDate,
      endDate: _selectedEndDate,
      isRepeat: _isRepeat,
    );
  }

  bool _isBudgetDataSufficient() {
    return _amountController.text.isNotEmpty &&
        _selectedTransactionType != 'Select Transaction Type' &&
        _selectedCategory != 'Select Category' &&
        _selectedWallet != 'Select Wallet' &&
        _selectedStartDate != null &&
        _selectedEndDate != null;
  }

  Future<void> _saveBudget() async {
    final data = _gatherBudgetData();
    try {
      await _apiService.addBudget(data);
    } catch (e) {
      print(e);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Budget'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
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
                            _selectedSubcategory = selectedData['subcategory'];
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
                                _selectedSubcategory,
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
              Row(
                children: [
                  Expanded(
                    child: DatePickerButton(
                      onDateSelected: (date) {
                        setState(() {
                          _selectedStartDate = date;
                        });
                      },
                    ),
                  ),
                  const SizedBox(
                      width: 16.0), // Add spacing between the two buttons
                  Expanded(
                    child: DatePickerButton(
                      onDateSelected: (date) {
                        setState(() {
                          _selectedEndDate = date;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
            ],
          ),
          if (!_isNumpadVisible)
            Positioned(
              bottom: 45.0,
              left: 16.0,
              right: 16.0,
              child: ElevatedButton(
                onPressed:
                    _isBudgetDataSufficient() ? () => _saveBudget() : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: _isBudgetDataSufficient()
                      ? Colors.greenAccent
                      : Colors.grey.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: const Text('Save'),
              ),
            ),
          if (_isNumpadVisible) ...[
            CustomNumpad(
              amountController: _amountController,
              onEnterPressed: _hideNumpad,
            ),
          ],
        ],
      ),
    );
  }
}
