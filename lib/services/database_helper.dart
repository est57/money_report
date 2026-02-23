import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction_model.dart';
import '../models/recurring_transaction_model.dart';
import '../models/category_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'money_report.db');
    return await openDatabase(
      path,
      version: 4,
      onCreate: (db, version) async {
        await _createTransactionsTable(db);
        await _createRecurringTransactionsTable(db);
        await _createCategoriesTable(db);
        await _seedDefaultCategories(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createRecurringTransactionsTable(db);
        }
        if (oldVersion < 3) {
          await _createCategoriesTable(db);
          await _seedDefaultCategories(db);
        }
        if (oldVersion < 4) {
          await db.execute(
            'ALTER TABLE categories ADD COLUMN budget REAL DEFAULT 0.0',
          );
        }
      },
    );
  }

  Future<void> _createTransactionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        amount REAL,
        isExpense INTEGER,
        date TEXT,
        category TEXT
      )
    ''');
  }

  Future<void> _createRecurringTransactionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE recurring_transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        amount REAL,
        isExpense INTEGER,
        category TEXT,
        frequency TEXT,
        nextDueDate TEXT
      )
    ''');
  }

  Future<void> _createCategoriesTable(Database db) async {
    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        type TEXT,
        iconKey TEXT,
        color INTEGER,
        budget REAL DEFAULT 0.0
      )
    ''');
  }

  Future<void> _seedDefaultCategories(Database db) async {
    // Check if table is empty first to avoid duplicates on bad upgrade logic
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM categories'),
    );
    if (count != null && count > 0) return;

    final List<Map<String, dynamic>> defaults = [
      // Expenses
      {
        'name': 'Food',
        'type': 'Expense',
        'iconKey': 'food',
        'color': 0xFFE53935,
      },
      {
        'name': 'Transport',
        'type': 'Expense',
        'iconKey': 'transport',
        'color': 0xFFFB8C00,
      },
      {
        'name': 'Shopping',
        'type': 'Expense',
        'iconKey': 'shopping',
        'color': 0xFF8E24AA,
      },
      {
        'name': 'Bills',
        'type': 'Expense',
        'iconKey': 'bills',
        'color': 0xFF1E88E5,
      },
      {
        'name': 'Entertainment',
        'type': 'Expense',
        'iconKey': 'entertainment',
        'color': 0xFFD81B60,
      },
      {
        'name': 'Health',
        'type': 'Expense',
        'iconKey': 'health',
        'color': 0xFF00897B,
      },
      {
        'name': 'Education',
        'type': 'Expense',
        'iconKey': 'education',
        'color': 0xFFFDD835,
      },
      {
        'name': 'Other',
        'type': 'Expense',
        'iconKey': 'other',
        'color': 0xFF757575,
      },

      // Income
      {
        'name': 'Salary',
        'type': 'Income',
        'iconKey': 'salary',
        'color': 0xFF43A047,
      },
      {
        'name': 'Bonus',
        'type': 'Income',
        'iconKey': 'bonus',
        'color': 0xFFC0CA33,
      },
      {
        'name': 'Award',
        'type': 'Income',
        'iconKey': 'award',
        'color': 0xFFFFB300,
      },
      {
        'name': 'Investment',
        'type': 'Income',
        'iconKey': 'investment',
        'color': 0xFF039BE5,
      },
      {
        'name': 'Other',
        'type': 'Income',
        'iconKey': 'other',
        'color': 0xFF757575,
      },
    ];

    for (var cat in defaults) {
      await db.insert('categories', cat);
    }
  }

  // Regular Transactions CRUD
  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<TransactionModel>> getTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => TransactionModel.fromMap(maps[i]));
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  // Recurring Transactions CRUD
  Future<int> insertRecurringTransaction(
    RecurringTransactionModel transaction,
  ) async {
    final db = await database;
    return await db.insert('recurring_transactions', transaction.toMap());
  }

  Future<List<RecurringTransactionModel>> getRecurringTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recurring_transactions',
      orderBy: 'nextDueDate ASC',
    );
    return List.generate(
      maps.length,
      (i) => RecurringTransactionModel.fromMap(maps[i]),
    );
  }

  Future<int> deleteRecurringTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'recurring_transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateRecurringTransaction(
    RecurringTransactionModel transaction,
  ) async {
    final db = await database;
    return await db.update(
      'recurring_transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  // Categories CRUD
  Future<int> insertCategory(CategoryModel category) async {
    final db = await database;
    return await db.insert('categories', category.toMap());
  }

  Future<List<CategoryModel>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      orderBy: 'name ASC', // Or custom order
    );
    return List.generate(maps.length, (i) => CategoryModel.fromMap(maps[i]));
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateCategory(CategoryModel category) async {
    final db = await database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<void> deleteAllData() async {
    final db = await database;
    await db.delete('transactions');
    await db.delete('recurring_transactions');
    // We typically don't delete categories on "Reset Data" unless requested,
    // but if it's "Factory Reset" maybe.
    // For now, let's keep categories.
  }

  Future<void> deleteAllCategories() async {
    final db = await database;
    await db.delete('categories');
  }
}
