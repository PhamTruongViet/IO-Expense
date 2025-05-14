import 'package:flutter/material.dart';
import 'package:io_expense_data/services/api_service.dart';

class TransactionTypesScreen extends StatefulWidget {
  const TransactionTypesScreen({super.key});

  @override
  State<TransactionTypesScreen> createState() => _TransactionTypesScreenState();
}

class _TransactionTypesScreenState extends State<TransactionTypesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, Map<String, List<String>>> transactionTypes = {};
  bool isLoading = true;
  String errorMessage = '';
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchTransactionTypes();
  }

  Future<void> _fetchTransactionTypes() async {
    try {
      if (await _apiService.hasInternetConnection()) {
        await _apiService.fetchAndStoreTransactionTypes();
      }
      final fetchedTransactionTypes = await _apiService.getTransactionTypes();
      setState(() {
        transactionTypes = fetchedTransactionTypes;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessage = 'Error fetching transaction types: $error';
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(child: Text(errorMessage));
    }

    if (transactionTypes.isEmpty) {
      return const Center(child: Text('No transaction types available.'));
    }

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Expense'),
            Tab(text: 'Income'),
            Tab(text: 'Debt/Loan'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildCategoryList('Expense'),
              _buildCategoryList('Income'),
              _buildCategoryList('Debt/Loan'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryList(String transactionType) {
    if (!transactionTypes.containsKey(transactionType)) {
      return const Center(child: Text('No categories available.'));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            onPressed: () async => _showAddMenu(transactionType),
            icon: const Icon(Icons.add),
            label: const Text('Add new category/subcategory'),
          ),
        ),
        Expanded(
          child: ListView(
            children: transactionTypes[transactionType]!.keys.map((category) {
              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ExpansionTile(
                  expansionAnimationStyle: AnimationStyle(curve: Curves.easeIn),
                  title: Text(category,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  children: transactionTypes[transactionType]![category]!
                      .map((subCategory) {
                    return ListTile(
                      title: Text(subCategory),
                      onTap: () {
                        Navigator.pop(context, {
                          'category': category,
                          'subcategory': subCategory,
                          'transactionType': transactionType
                        });
                      },
                      onLongPress: () async {
                        // await _apiService.deleteSubcategory(subCategory);
                        setState(() {
                          transactionTypes[transactionType]![category]!
                              .remove(subCategory);
                        });
                      },
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showAddMenu(String transactionType) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Add new category/subcategory'),
          children: [
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                _showAddCategoryDialog(transactionType);
              },
              child: const Text('Add Category'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                _showAddSubCategoryDialog(transactionType);
              },
              child: const Text('Add Subcategory'),
            ),
          ],
        );
      },
    );
  }

  void _showAddCategoryDialog(String transactionType) {
    final categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Category'),
          content: TextField(
            controller: categoryController,
            decoration: const InputDecoration(labelText: 'Category'),
          ),
          actions: [
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final category = categoryController.text;
                          if (category.isNotEmpty) {
                            try {
                              setState(() {
                                if (!transactionTypes
                                    .containsKey(transactionType)) {
                                  transactionTypes[transactionType] = {};
                                }
                                if (!transactionTypes[transactionType]!
                                    .containsKey(category)) {
                                  transactionTypes[transactionType]![category] =
                                      [];
                                }
                              });

                              if (await _apiService.hasInternetConnection()) {
                                await _apiService.addCategory(
                                    transactionType, category);
                              }
                              Navigator.pop(context);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Error adding category: $e')),
                              );
                            }
                          }
                        },
                        child: const Text('Add'),
                      ),
                    ])),
          ],
        );
      },
    );
  }

  void _showAddSubCategoryDialog(String transactionType) {
    final subCategoryController = TextEditingController();
    String? selectedCategory;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Subcategory'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: selectedCategory,
                    hint: const Text('Select Category'),
                    items: transactionTypes[transactionType]!
                        .keys
                        .map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedCategory = newValue;
                      });
                    },
                  ),
                  TextField(
                    controller: subCategoryController,
                    decoration: const InputDecoration(labelText: 'Subcategory'),
                  ),
                ],
              );
            },
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final subCategory = subCategoryController.text;
                      if (selectedCategory != null && subCategory.isNotEmpty) {
                        try {
                          await _apiService.addSubcategory(
                              transactionType, selectedCategory!, subCategory);
                          setState(() {
                            transactionTypes[transactionType]![
                                    selectedCategory]!
                                .add(subCategory);
                          });
                          Navigator.pop(context);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Error adding subcategory: $e')),
                          );
                        }
                      }
                    },
                    child: const Text('Add'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
