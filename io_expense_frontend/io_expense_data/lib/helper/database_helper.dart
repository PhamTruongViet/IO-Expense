import 'dart:convert';
import 'package:io_expense_data/models/budget_data.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'app_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount REAL,
            details TEXT,
            transactionType TEXT,
            category TEXT,
            subcategory TEXT,
            walletId INTEGER,
            filePath TEXT,
            date TEXT
          )
        ''');
        db.execute('''
          CREATE TABLE transaction_types (
            id TEXT PRIMARY KEY,
            name TEXT,
            categories TEXT
          )
        ''');
        db.execute('''
          CREATE TABLE categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            transactionType TEXT,
            category TEXT
          )
        ''');
        db.execute('''
          CREATE TABLE subcategories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            transactionType TEXT,
            category TEXT,
            subcategory TEXT
          )
        ''');
        db.execute('''
          CREATE TABLE wallets (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            balance REAL,
            date TEXT
          )
        ''');
        db.execute('''
          CREATE TABLE budgets (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount REAL,
            details TEXT,
            startDate TEXT,
            endDate TEXT,
            category TEXT,
            walletId TEXT,
            isRepeat INTEGER
          )
        ''');
      },
    );
  }

  Future<void> insertTransaction(Map<String, dynamic> transaction) async {
    final db = await database;
    await db.insert('transactions', transaction);
    await updateWalletBalanceBasedOnTransaction(transaction, false);
  }

  Future<void> updateTransaction(
      String id, Map<String, dynamic> transaction) async {
    final db = await database;
    await db
        .update('transactions', transaction, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getTransactions() async {
    final db = await database;
    return await db.query('transactions');
  }

  Future<List<Map<String, dynamic>>> getTransactionsByWallet(
      String walletId) async {
    final db = await database;
    return await db
        .query('transactions', where: 'walletId = ?', whereArgs: [walletId]);
  }

  Future<Map<String, dynamic>> getLatestTransaction() async {
    final db = await database;
    final result = await db.query('transactions', orderBy: 'id DESC', limit: 1);
    return result.first;
  }

  Future<void> deleteTransaction(int id) async {
    final db = await database;
    final transaction =
        (await db.query('transactions', where: 'id = ?', whereArgs: [id]))[0];
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
    await updateWalletBalanceBasedOnTransaction(transaction, true);
  }

  Future<void> clearTransactions() async {
    final db = await database;
    await db.delete('transactions');
  }

  Future<void> updateTransactionImagePath(int id, String imagePath) async {
    final db = await database;
    await db.update(
      'transactions',
      {'imagePath': imagePath},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<String?> getTransactionImagePath(int id) async {
    final db = await database;
    final result = await db.query(
      'transactions',
      columns: ['imagePath'],
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return result.first['imagePath'] as String?;
    }
    return null;
  }

  Future<void> insertWallet(Map<String, dynamic> wallet) async {
    final db = await database;
    await db.insert('wallets', wallet);
  }

  Future<void> updateWallet(int id, Map<String, dynamic> wallet) async {
    final db = await database;
    await db.update('wallets', wallet, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateWalletBalanceBasedOnTransaction(
      Map<String, dynamic> transaction, bool isDelete) async {
    var walletId = transaction['walletId'];
    if (walletId is! int) {
      walletId = int.parse(walletId);
    }
    final double amount = transaction['amount'];
    final String type = transaction['transactionType'];

    final wallet = await getWalletById(walletId);

    if (wallet != null) {
      double newBalance = wallet['balance'];

      if (type == 'Income' && !isDelete) {
        newBalance += amount;
      } else if (type == 'Expense' && !isDelete) {
        newBalance -= amount;
      } else if (type == 'Income' && isDelete) {
        newBalance -= amount;
      } else if (type == 'Expense' && isDelete) {
        newBalance += amount;
      }

      await updateWallet(walletId, {'balance': newBalance});
    }
  }

  Future<List<Map<String, dynamic>>> getWallets() async {
    final db = await database;
    return await db.query('wallets');
  }

  Future<Map<String, dynamic>?> getWalletById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'wallets',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return maps.first;
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getMostUsedWalletByTransaction(
      String category) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT walletId, SUM(amount) as totalAmount
      FROM transactions
      WHERE category = ?
      GROUP BY walletId
      ORDER BY totalAmount DESC
      LIMIT 1
    ''', [category]);

    if (result.isNotEmpty) {
      return await getWalletById(result.first['walletId'] as int);
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>> getLatestWallet() async {
    final db = await database;
    final result = await db.query('wallets', orderBy: 'id DESC', limit: 1);
    return result.first;
  }

  Future<double?> getBalance(int walletId) async {
    final db = await database;
    final result = await db.query(
      'wallets',
      columns: ['balance'],
      where: 'id = ?',
      whereArgs: [walletId],
    );
    if (result.isNotEmpty) {
      return result.first['balance'] as double?;
    }
    return null;
  }

  Future<void> deleteWallet(int id) async {
    final db = await database;
    await db.delete('wallets', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> insertBudget(Map<String, dynamic> budget) async {
    final db = await database;
    await db.insert('budgets', budget);
  }

  Future<void> updateBudget(int id, Map<String, dynamic> budget) async {
    final db = await database;
    await db.update('budgets', budget, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAllBudgets() async {
    final db = await database;
    return await db.query('budgets');
  }

  Future<List<Map<String, dynamic>>> getBudgetsByWallet(String walletId) async {
    final db = await database;
    return await db
        .query('budgets', where: 'walletId = ?', whereArgs: [walletId]);
  }

  Future<budget_data> getBudgetByCategory(String category, String date) async {
    final db = await database;
    final result = await db.query(
      'budgets',
      where: 'category = ? AND startDate <= ? AND endDate >= ?',
      whereArgs: [category, date, date],
    );

    return budget_data.fromMap(result.first);
  }

  Future<void> deleteBudget(String id) async {
    final db = await database;
    await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> insertTransactionType(
      Map<String, dynamic> transactionType) async {
    final db = await database;
    await db.insert('transaction_types', transactionType);
  }

  Future<void> updateTransactionType(
      String id, Map<String, dynamic> category) async {
    final db = await database;

    await db.update('transaction_types', {'categories': json.encode(category)},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getTransactionTypes() async {
    final db = await database;
    return await db.query('transaction_types');
  }

  Future<Map<String, dynamic>?> getTransactionTypeById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transaction_types',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return maps.first;
    } else {
      return null;
    }
  }

  Future<String> getTransactionTypeIdByName(String name) async {
    final db = await database;
    return (await db.query('transaction_types',
        where: 'name = ?', whereArgs: [name]))[0]['id'] as String;
  }

  Future<void> deleteTransactionType(String id) async {
    final db = await database;
    await db.delete('transaction_types', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> insertCategory(String transactionType, String category) async {
    final db = await database;
    await db.insert('categories', {
      'transactionType': transactionType,
      'category': category,
    });
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await database;
    return await db.query('categories');
  }

  Future<void> deleteCategory(int id) async {
    final db = await database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> addCategoryToTransactionType(String id, String category) async {
    final transactionType = await getTransactionTypeById(id);

    if (transactionType != null) {
      Map<String, dynamic> categories =
          Map<String, dynamic>.from(jsonDecode(transactionType['categories']));
      if (!categories.containsKey(category)) {
        categories[category] = [];
      }

      // transactionType['categories'] = jsonEncode(categories);
      await updateTransactionType(id, categories);
    }
  }

  Future<void> removeCategoryFromTransactionType(
      String id, String category) async {
    final transactionType = await getTransactionTypeById(id);

    if (transactionType != null) {
      List<String> categories =
          List<String>.from(jsonDecode(transactionType['categories']));
      categories.remove(category);
      transactionType['categories'] = jsonEncode(categories);
      await updateTransactionType(id, transactionType);
    }
  }

  Future<void> addSubcategoryToCategory(
      String id, String category, String subcategory) async {
    final transactionType = await getTransactionTypeById(id);

    if (transactionType != null) {
      Map<String, dynamic> categories =
          Map<String, dynamic>.from(jsonDecode(transactionType['categories']));
      if (categories.containsKey(category)) {
        List<String> subcategories = List<String>.from(categories[category]);
        if (!subcategories.contains(subcategory)) {
          subcategories.add(subcategory);
          categories[category] = subcategories;
        }
      } else {
        categories[category] = [subcategory];
      }

      await updateTransactionType(id, categories);
    }
  }

  Future<void> removeSubcategoryFromCategory(
      String id, String category, String subcategory) async {
    final transactionType = await getTransactionTypeById(id);

    if (transactionType != null) {
      Map<String, dynamic> categories =
          Map<String, dynamic>.from(jsonDecode(transactionType['categories']));
      if (categories.containsKey(category)) {
        List<String> subcategories = List<String>.from(categories[category]);
        if (subcategories.contains(subcategory)) {
          subcategories.remove(subcategory);
          categories[category] = subcategories;
        }
      }

      await updateTransactionType(id, categories);
    }
  }

  Future<void> insertSubcategory(
      String transactionType, String category, String subcategory) async {
    final db = await database;
    await db.insert('subcategories', {
      'transactionType': transactionType,
      'category': category,
      'subcategory': subcategory,
    });
  }

  Future<List<Map<String, dynamic>>> getSubcategories() async {
    final db = await database;
    return await db.query('subcategories');
  }

  Future<void> deleteSubcategory(int id) async {
    final db = await database;
    await db.delete('subcategories', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getTransactionsForCurrentWeek() async {
    final db = await database;
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final endOfWeek = DateTime(now.year, now.month, now.day).add(
        Duration(days: 7 - now.weekday, hours: 23, minutes: 59, seconds: 59));
    return await db.query(
      'transactions',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startOfWeek.toIso8601String(), endOfWeek.toIso8601String()],
    );
  }

  Future<List<Map<String, dynamic>>> getTransactionsForCurrentMonth() async {
    final db = await database;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth =
        DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1));

    return await db.query(
      'transactions',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startOfMonth.toIso8601String(), endOfMonth.toIso8601String()],
    );
  }

  Future<List<Map<String, dynamic>>> getTransactionsForCurrentYear() async {
    final db = await database;
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear =
        DateTime(now.year + 1, 1, 1).subtract(const Duration(days: 1));

    return await db.query(
      'transactions',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startOfYear.toIso8601String(), endOfYear.toIso8601String()],
    );
  }

  Future<void> deleteDatabaseFile() async {
    String path = join(await getDatabasesPath(), 'app_database.db');
    await deleteDatabase(path);
    _database = null;
  }
}
