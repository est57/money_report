import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:hugeicons/hugeicons.dart';
import '../providers/transaction_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/theme.dart';
import '../models/transaction_model.dart';
import 'add_transaction_screen.dart';

class TransactionSearchDelegate extends SearchDelegate {
  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: theme.scaffoldBackgroundColor,
        iconTheme: theme.iconTheme.copyWith(color: Colors.grey),
        titleTextStyle: TextStyle(
          color: theme.textTheme.bodyLarge?.color,
          fontSize: 18,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.grey),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildList(context);
  }

  Widget _buildList(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final List<TransactionModel> results = provider.searchTransactions(query);
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            HugeIcon(
              icon: HugeIcons.strokeRoundedSearch01,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text('No transactions found', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: settings.currencySymbol,
      decimalDigits: 0,
    );

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final tx = results[index];
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              '${DateFormat('dd MMM').format(tx.date)} • ${tx.category}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            trailing: Text(
              (tx.isExpense ? '- ' : '+ ') + currencyFormat.format(tx.amount),
              style: TextStyle(
                color: tx.isExpense
                    ? AppTheme.expenseColor
                    : AppTheme.incomeColor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddTransactionScreen(transaction: tx),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
