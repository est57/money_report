import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/database_helper.dart';

import '../models/recurring_transaction_model.dart';

class TransactionProvider with ChangeNotifier {
  List<TransactionModel> _transactions = [];
  List<RecurringTransactionModel> _recurringTransactions = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<TransactionModel> get transactions => _transactions;
  List<RecurringTransactionModel> get recurringTransactions =>
      _recurringTransactions;

  double get totalBalance {
    return totalIncome - totalExpense;
  }

  double get totalIncome {
    return _transactions
        .where((tx) => !tx.isExpense)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get totalExpense {
    return _transactions
        .where((tx) => tx.isExpense)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  Future<void> fetchTransactions() async {
    try {
      _transactions = await _dbHelper.getTransactions();
      await fetchRecurringTransactions();
      await checkAndGenerateRecurringTransactions();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
    }
  }

  Future<void> fetchRecurringTransactions() async {
    try {
      _recurringTransactions = await _dbHelper.getRecurringTransactions();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching recurring transactions: $e');
    }
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _dbHelper.insertTransaction(transaction);
    await fetchTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    await _dbHelper.deleteTransaction(id);
    await fetchTransactions();
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await _dbHelper.updateTransaction(transaction);
    await fetchTransactions();
  }

  // Recurring Transactions Methods
  Future<void> addRecurringTransaction(
    RecurringTransactionModel transaction,
  ) async {
    await _dbHelper.insertRecurringTransaction(transaction);
    await fetchRecurringTransactions();
    await checkAndGenerateRecurringTransactions(); // Check immediately
  }

  Future<void> deleteRecurringTransaction(int id) async {
    await _dbHelper.deleteRecurringTransaction(id);
    await fetchRecurringTransactions();
  }

  Future<void> updateRecurringTransaction(
    RecurringTransactionModel transaction,
  ) async {
    await _dbHelper.updateRecurringTransaction(transaction);
    await fetchRecurringTransactions();
  }

  Future<void> checkAndGenerateRecurringTransactions() async {
    try {
      final now = DateTime.now();
      bool changesMade = false;

      for (var recurring in _recurringTransactions) {
        DateTime nextDue = recurring.nextDueDate;

        // While next due date is in the past or today
        while (nextDue.isBefore(now) || isSameDay(nextDue, now)) {
          // Generate Transaction
          final newTx = TransactionModel(
            title: recurring.title,
            amount: recurring.amount,
            isExpense: recurring.isExpense,
            date: nextDue,
            category: recurring.category,
          );
          await _dbHelper.insertTransaction(newTx);

          // Update Next Due Date (Add 1 Month)
          // Handle month overflow correctly
          nextDue = DateTime(
            nextDue.year,
            nextDue.month + 1,
            nextDue.day,
            nextDue.hour,
            nextDue.minute,
          );

          // Update recurring record
          final updatedRecurring = RecurringTransactionModel(
            id: recurring.id,
            title: recurring.title,
            amount: recurring.amount,
            isExpense: recurring.isExpense,
            category: recurring.category,
            frequency: recurring.frequency,
            nextDueDate: nextDue,
          );

          await _dbHelper.updateRecurringTransaction(updatedRecurring);
          changesMade = true;
        }
      }

      if (changesMade) {
        _transactions = await _dbHelper.getTransactions();
        _recurringTransactions = await _dbHelper.getRecurringTransactions();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error checking recurring transactions: $e');
    }
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> importData(Map<String, dynamic> data) async {
    // 1. Clear All Data
    await _dbHelper.deleteAllData();

    // 2. Insert Transactions
    if (data.containsKey('transactions')) {
      final List<dynamic> txs = data['transactions'];
      for (var txMap in txs) {
        // Reset ID to let AutoIncrement work or keep ID if we want exact clone.
        // For backup/restore, keeping ID is risky if we ever merge.
        // But since we wiped DB, keeping ID is fine or better let DB decide.
        // Safer: Ignore ID from backup and let DB generate new sequential IDs.
        final original = TransactionModel.fromMap(txMap);
        final newTx = TransactionModel(
          title: original.title,
          amount: original.amount,
          isExpense: original.isExpense,
          date: original.date,
          category: original.category,
        );
        await _dbHelper.insertTransaction(newTx);
      }
    }

    // 3. Insert Recurring
    if (data.containsKey('recurring_transactions')) {
      final List<dynamic> recs = data['recurring_transactions'];
      for (var recMap in recs) {
        final original = RecurringTransactionModel.fromMap(recMap);
        final newRec = RecurringTransactionModel(
          title: original.title,
          amount: original.amount,
          isExpense: original.isExpense,
          category: original.category,
          frequency: original.frequency,
          nextDueDate: original.nextDueDate,
        );
        await _dbHelper.insertRecurringTransaction(newRec);
      }
    }

    await fetchTransactions();
  }

  List<TransactionModel> getFilteredTransactions(
    DateTime start,
    DateTime end,
    String type, // 'All', 'Income', 'Expense'
  ) {
    return _transactions.where((tx) {
      final date = tx.date;
      final isDateInRange =
          date.isAfter(start.subtract(const Duration(days: 1))) &&
          date.isBefore(end.add(const Duration(days: 1)));

      if (!isDateInRange) return false;

      if (type == 'Income') return !tx.isExpense;
      if (type == 'Expense') return tx.isExpense;
      return true; // 'All'
    }).toList();
  }

  List<TransactionModel> searchTransactions(String query) {
    if (query.isEmpty) return _transactions;
    return _transactions.where((tx) {
      final titleLower = tx.title.toLowerCase();
      final categoryLower = tx.category.toLowerCase();
      final queryLower = query.toLowerCase();
      return titleLower.contains(queryLower) ||
          categoryLower.contains(queryLower);
    }).toList();
  }

  Map<String, double> getCategoryStats(bool isExpense) {
    Map<String, double> stats = {};
    final filtered = _transactions.where((tx) => tx.isExpense == isExpense);

    for (var tx in filtered) {
      if (stats.containsKey(tx.category)) {
        stats[tx.category] = stats[tx.category]! + tx.amount;
      } else {
        stats[tx.category] = tx.amount;
      }
    }
    return stats;
  }
}
