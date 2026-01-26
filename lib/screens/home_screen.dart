import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:hugeicons/hugeicons.dart';
import '../providers/transaction_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/theme.dart';
import '../models/transaction_model.dart';
import 'add_transaction_screen.dart';
import 'transaction_search_delegate.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildTransactionList(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: settings.currencySymbol,
      decimalDigits: 0,
    );
    final padding = MediaQuery.of(context).padding;

    // Fixed header with gradient background
    // We include top padding for status bar + extra space
    return Container(
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
      padding: EdgeInsets.only(
        top: padding.top + 10,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Balance',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              IconButton(
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedSearch01,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () {
                  showSearch(
                    context: context,
                    delegate: TransactionSearchDelegate(),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            currencyFormat.format(provider.totalBalance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem(
                  'Income',
                  provider.totalIncome,
                  Colors.lightGreenAccent.shade100,
                  HugeIcons.strokeRoundedArrowDown01,
                  currencyFormat,
                ),
                Container(width: 1, height: 40, color: Colors.white24),
                _buildSummaryItem(
                  'Expense',
                  provider.totalExpense,
                  Colors.redAccent.shade100,
                  HugeIcons.strokeRoundedArrowUp01,
                  currencyFormat,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildBudgetProgress(context, provider, settings),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildBudgetProgress(
    BuildContext context,
    TransactionProvider provider,
    SettingsProvider settings,
  ) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    // Calculate this month's expense
    final monthlyExpense = provider
        .getFilteredTransactions(startOfMonth, endOfMonth, 'Expense')
        .fold(0.0, (sum, tx) => sum + tx.amount);

    final isSet = settings.monthlyBudget > 0;
    final progress = isSet
        ? (monthlyExpense / settings.monthlyBudget).clamp(0.0, 1.0)
        : 0.0;
    final isOverBudget = isSet && monthlyExpense > settings.monthlyBudget;

    return GestureDetector(
      onTap: () => _showBudgetDialog(context, settings),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Monthly Budget',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                if (!isSet)
                  const Text(
                    'Tap to set',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  )
                else
                  Text(
                    '${monthlyExpense.toStringAsFixed(0)} / ${settings.monthlyBudget.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isOverBudget ? Colors.redAccent : Colors.white,
                ),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBudgetDialog(BuildContext context, SettingsProvider settings) {
    final controller = TextEditingController(
      text: settings.monthlyBudget > 0
          ? settings.monthlyBudget.toStringAsFixed(0)
          : '',
    );

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const HugeIcon(
                  icon: HugeIcons.strokeRoundedAnalytics01,
                  color: Colors.teal,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Set Monthly Budget',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your target monthly spending limit',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.1),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      settings.currencySymbol,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final amount = double.tryParse(controller.text) ?? 0.0;
                        settings.setMonthlyBudget(amount);
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    String title,
    double amount,
    Color color,
    dynamic icon, // Changed to dynamic
    NumberFormat format,
  ) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: HugeIcon(icon: icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              Text(
                format.format(amount),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        if (provider.transactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedInvoice01,
                  size: 80,
                  color: Colors.grey,
                ),
                SizedBox(height: 20),
                Text(
                  'No transactions yet',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          itemCount: provider.transactions.length,
          itemBuilder: (context, index) {
            final tx = provider.transactions[index];
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
                boxShadow: Theme.of(context).brightness == Brightness.light
                    ? AppTheme.softShadow
                    : [],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: tx.isExpense
                      ? AppTheme.expenseColor.withOpacity(0.1)
                      : AppTheme.incomeColor.withOpacity(0.1),
                  child: HugeIcon(
                    icon: tx.isExpense
                        ? HugeIcons.strokeRoundedShoppingCart01
                        : HugeIcons.strokeRoundedMoney03,
                    color: tx.isExpense
                        ? AppTheme.expenseColor
                        : AppTheme.incomeColor,
                    size: 24,
                  ),
                ),
                title: Text(
                  tx.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedCalendar03,
                            size: 12,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('dd MMM yyyy').format(tx.date),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tx.category,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                trailing: Text(
                  (tx.isExpense ? '- ' : '+ ') +
                      currencyFormat.format(tx.amount),
                  style: TextStyle(
                    color: tx.isExpense
                        ? AppTheme.expenseColor
                        : AppTheme.incomeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                onLongPress: () {
                  _showTransactionOptions(context, tx, provider);
                },
              ),
            );
          },
        );
      },
    );
  }

  void _showTransactionOptions(
    BuildContext context,
    TransactionModel tx,
    TransactionProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Transaction Options',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const HugeIcon(
                    icon: HugeIcons.strokeRoundedPencilEdit02,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                title: const Text('Edit Transaction'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          AddTransactionScreen(transaction: tx),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const HugeIcon(
                    icon: HugeIcons.strokeRoundedDelete02,
                    color: Colors.red,
                    size: 24,
                  ),
                ),
                title: const Text(
                  'Delete Transaction',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _showDeleteConfirmation(context, provider, tx.id!);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    TransactionProvider provider,
    int id,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Transaction?'),
        content: const Text(
          'Are you sure you want to delete this transaction?',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () {
              provider.deleteTransaction(id);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}
