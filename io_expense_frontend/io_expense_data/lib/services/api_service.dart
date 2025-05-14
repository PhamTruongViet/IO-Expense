import 'package:http/http.dart' as http;
import '/models/budget_data.dart';
import '/models/transaction_data.dart';
import 'dart:convert';
import 'auth_service.dart';
import 'notification_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '/helper/database_helper.dart';

class ApiService {
  final AuthService _authService = AuthService();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  String? userId;
  String? baseUrl = 'http://192.168.1.48:8080/api';
  // String? baseUrl = 'http://10.0.2.2:8080/api';
  String? transactionTypeId;
  String? category;

  // Check for internet connection
  Future<bool> hasInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  // Stream for connectivity changes
  Stream<ConnectivityResult> get connectivityStream =>
      Connectivity().onConnectivityChanged;

  // Start listening to connectivity changes
  void startListeningToConnectivity() {
    connectivityStream.listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        syncOfflineData();
      }
    });
  }

  // Sync all data from SQLite to server
  Future<void> syncOfflineData() async {
    await syncOfflineCategories();
    await syncOfflineSubcategories();
    await syncOfflineTransactions();
  }

  // Fetch transaction types from server and store in SQLite
  Future<void> fetchAndStoreTransactionTypes() async {
    userId = await _authService.getUserId();
    final url = Uri.parse('$baseUrl/users/$userId/transactiontypes');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        for (var item in data) {
          final String id = item['id'];
          final String name = item['name'];
          final Map<String, dynamic> categories = item['categories'];

          final transactionType = {
            'id': id,
            'name': name,
            'categories': json.encode(categories),
          };

          final existingRecords = await _dbHelper.getTransactionTypeById(id);
          print('hello');
          if (existingRecords == null) {
            await _dbHelper.insertTransactionType(transactionType);
          }
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Retrieve transaction types from SQLite
  Future<Map<String, Map<String, List<String>>>> getTransactionTypes() async {
    final transactionTypes = await _dbHelper.getTransactionTypes();
    final Map<String, Map<String, List<String>>> result = {};

    for (var type in transactionTypes) {
      final String name = type['name'];
      final Map<String, dynamic> categories = json.decode(type['categories']);

      final Map<String, List<String>> parsedCategories = {};
      categories.forEach((key, value) {
        parsedCategories[key] = List<String>.from(value);
      });

      result[name] = parsedCategories;
    }

    return result;
  }

  // Add wallet and sync if online
  Future<void> addWallet(Map<String, dynamic> wallet) async {
    userId = await _authService.getUserId();
    await _dbHelper.insertWallet(wallet);
    print('Wallet added');
    await syncOfflineWallets();
  }

  Future<void> syncOfflineWallets() async {
    if (!await hasInternetConnection()) return;

    final wallets = await _dbHelper.getWallets();
    final url = Uri.parse('$baseUrl/users/$userId/wallets');

    for (var wallet in wallets) {
      try {
        final modifiedWallet = Map<String, dynamic>.from(wallet);

        if (modifiedWallet['date'] is DateTime) {
          modifiedWallet['date'] =
              (modifiedWallet['date'] as DateTime).toIso8601String();
        }

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(modifiedWallet),
        );

        if (response.statusCode != 200) {
          print('Failed to sync wallet: ${response.statusCode}');
        }
      } catch (e) {
        print('Error syncing wallet: $e');
      }
    }
  }

  //Add budget and sync if online
  Future<void> addBudget(budget_data budget) async {
    userId = await _authService.getUserId();
    await _dbHelper.insertBudget(budget.toMap());
    await syncOfflineBudgets();
  }

  // Sync offline budgets to server
  Future<void> syncOfflineBudgets() async {
    if (!await hasInternetConnection()) return;

    final budgets = await _dbHelper.getAllBudgets();
    final url = Uri.parse('$baseUrl/users/$userId/budgets');

    for (var budget in budgets) {
      try {
        final modifiedBudget = Map<String, dynamic>.from(budget);

        if (modifiedBudget['startDate'] is DateTime) {
          modifiedBudget['startDate'] =
              (modifiedBudget['startDate'] as DateTime).toIso8601String();
        }

        if (modifiedBudget['endDate'] is DateTime) {
          modifiedBudget['endDate'] =
              (modifiedBudget['endDate'] as DateTime).toIso8601String();
        }

        print(modifiedBudget);
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(modifiedBudget),
        );

        if (response.statusCode != 200) {
          print('Failed to sync budget: ${response.statusCode}');
        }
      } catch (e) {
        print('Error syncing budget: $e');
      }
    }
  }

  // Add transaction category and sync if online
  Future<void> addCategory(String transactionType, String category) async {
    userId = await _authService.getUserId();
    transactionTypeId =
        await _dbHelper.getTransactionTypeIdByName(transactionType);
    if (userId == null) {
      throw Exception('User ID is null');
    }
    await _dbHelper.insertCategory(transactionType, category);
    await _dbHelper.addCategoryToTransactionType(
        await _dbHelper.getTransactionTypeIdByName(transactionType), category);
    await syncOfflineCategories();
  }

  // Sync offline categories to server
  Future<void> syncOfflineCategories() async {
    if (!await hasInternetConnection()) return;

    final categories = await _dbHelper.getCategories();
    final url = Uri.parse(
        '$baseUrl/users/$userId/transactiontypes/$transactionTypeId/categories');

    for (var category in categories) {
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode([category['category']]),
        );

        if (response.statusCode != 200) {
          print('Failed to sync category: ${response.statusCode}');
        }
      } catch (e) {
        print('Error syncing category: $e');
      }
    }
  }

  // Add transaction subcategory and sync if online
  Future<void> addSubcategory(
      String transactionType, String category, String subcategory) async {
    userId = await _authService.getUserId();
    transactionTypeId =
        await _dbHelper.getTransactionTypeIdByName(transactionType);
    this.category = category;
    await _dbHelper.insertSubcategory(transactionType, category, subcategory);
    await _dbHelper.addSubcategoryToCategory(
        await _dbHelper.getTransactionTypeIdByName(transactionType),
        category,
        subcategory);
    await syncOfflineSubcategories();
  }

  // Future<void> deleteSubcategory(String subCategoryName) async {
  //   userId = await _authService.getUserId();
  //   await _dbHelper.getSub
  //   await _dbHelper.deleteSubcategory(subCategoryName);
  //   await syncOfflineSubcategories();
  // }

  // Sync offline subcategories to server
  Future<void> syncOfflineSubcategories() async {
    if (!await hasInternetConnection()) return;

    final subcategories = await _dbHelper.getSubcategories();
    final url = Uri.parse(
        '$baseUrl/users/$userId/transactiontypes/$transactionTypeId/categories/$category/subcategories');
    for (var subcategory in subcategories) {
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: subcategory['subcategory'],
        );

        if (response.statusCode != 200) {
          print('Failed to sync subcategory: ${response.statusCode}');
        }
      } catch (e) {
        print('Error syncing subcategory: $e');
      }
    }
  }

  Future<void> addImage(String transactionId, String photoPath) async {
    userId = await _authService.getUserId();
    final url =
        Uri.parse('$baseUrl/users/$userId/transactions/$transactionId/photo');
    final request = http.MultipartRequest('POST', url)
      ..headers['Content-Type'] = 'multipart/form-data; boundary=<boundary>'
      ..files.add(await http.MultipartFile.fromPath('photo', photoPath));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        print('Photo uploaded successfully');
      } else {
        print('Failed to upload photo: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  // Future<void> deleteImage(String transactionId, String fileName) async {
  //   userId = await _authService.getUserId();
  //   final url = Uri.parse(
  //       '$baseUrl/users/$userId/transactions/$transactionId/photo/$fileName');
  //
  //   try {
  //     final response = await http.delete(url);
  //
  //     if (response.statusCode != 200) {
  //       print('Failed to delete image: ${response.statusCode}');
  //     } else {
  //       print('Image deleted successfully');
  //     }
  //   } catch (e) {
  //     print('Error deleting image: $e');
  //   }
  // }

  // Add transaction and sync if online
  Future<void> addTransaction(transaction_data transaction) async {
    userId = await _authService.getUserId();
    await _dbHelper.insertTransaction(transaction.toMap());
    print('Transaction added');
    NotificationService notificationService = NotificationService();
    notificationService.showBudgetStatusNotification(transaction);
    await syncOfflineTransactions();
  }

  // Sync offline transactions to server
  Future<void> syncOfflineTransactions() async {
    if (!await hasInternetConnection()) return;

    final transactions = await _dbHelper.getTransactions();
    final url = Uri.parse('$baseUrl/users/$userId/transactions');

    for (var transaction in transactions) {
      try {
        final modifiedTransaction = Map<String, dynamic>.from(transaction);

        if (modifiedTransaction['walletId'] is! String) {
          modifiedTransaction['walletId'] =
              modifiedTransaction['walletId'].toString();
        }

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(modifiedTransaction),
        );

        if (response.statusCode != 200) {
          print('Failed to sync transaction: ${response.statusCode}');
        }

        final photoPath = transaction['filePath'];
        print('ImgPath: $photoPath');
        if (photoPath != null && photoPath.isNotEmpty) {
          final lastTransaction = await _dbHelper.getLatestTransaction();
          final transactionId = lastTransaction['id'].toString();

          addImage(transactionId, photoPath);
        }
      } catch (e) {
        print('Error syncing transaction: $e');
      }
    }
  }
}
