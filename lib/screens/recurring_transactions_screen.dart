import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:hugeicons/hugeicons.dart';
import '../providers/transaction_provider.dart';
import '../providers/settings_provider.dart';
import '../models/recurring_transaction_model.dart';
import '../utils/theme.dart';
import 'add_recurring_transaction_screen.dart';

class RecurringTransactionsScreen extends StatefulWidget {
  const RecurringTransactionsScreen({super.key});

  @override
  State<RecurringTransactionsScreen> createState() =>
      _RecurringTransactionsScreenState();
}

class _RecurringTransactionsScreenState
    extends State<RecurringTransactionsScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Provider.of<TransactionProvider>(
        context,
        listen: false,
      ).fetchRecurringTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recurring Transactions',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
        ),
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          final recurringList = provider.recurringTransactions;
          if (recurringList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const HugeIcon(
                      icon: HugeIcons.strokeRoundedRepeat,
                      size: 48,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No recurring transactions',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap + to add one (e.g. Rent, Salary)',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: recurringList.length,
            itemBuilder: (context, index) {
              final tx = recurringList[index];
              return _buildRecurringItem(context, tx);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddRecurringTransactionScreen(),
            ),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildRecurringItem(
    BuildContext context,
    RecurringTransactionModel tx,
  ) {
    final settings = Provider.of<SettingsProvider>(context);
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: settings.currencySymbol,
      decimalDigits: 0,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: tx.isExpense
              ? AppTheme.expenseColor.withOpacity(0.1)
              : AppTheme.incomeColor.withOpacity(0.1),
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedRepeat,
            color: tx.isExpense ? AppTheme.expenseColor : AppTheme.incomeColor,
            size: 24,
          ),
        ),
        title: Text(
          tx.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${tx.frequency} • Next: ${DateFormat('dd MMM yyyy').format(tx.nextDueDate)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              (tx.isExpense ? '- ' : '+ ') + currencyFormat.format(tx.amount),
              style: TextStyle(
                color: tx.isExpense
                    ? AppTheme.expenseColor
                    : AppTheme.incomeColor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'Edit') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          AddRecurringTransactionScreen(transaction: tx),
                    ),
                  );
                } else if (value == 'Delete') {
                  _showDeleteConfirm(context, tx);
                }
              },
              itemBuilder: (BuildContext context) {
                return {'Edit', 'Delete'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, RecurringTransactionModel tx) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Stop Recurring?'),
        content: Text(
          'Are you sure you want to stop recurring transaction "${tx.title}"?',
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text(
              'Stop & Delete',
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () {
              Provider.of<TransactionProvider>(
                context,
                listen: false,
              ).deleteRecurringTransaction(tx.id!);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}
