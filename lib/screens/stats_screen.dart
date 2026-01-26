import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/theme.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  bool _isExpense = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80, // Taller for "smooth" header look
        title: const Text('Statistics', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
            // borderRadius removed as per user request
            boxShadow: [
              // Add shadow for depth
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Toggle
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isExpense = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _isExpense
                            ? AppTheme.expenseColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow:
                            _isExpense &&
                                Theme.of(context).brightness == Brightness.light
                            ? AppTheme.softShadow
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          'Expense',
                          style: TextStyle(
                            color: _isExpense ? Colors.white : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isExpense = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_isExpense
                            ? AppTheme.incomeColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow:
                            !_isExpense &&
                                Theme.of(context).brightness == Brightness.light
                            ? AppTheme.softShadow
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          'Income',
                          style: TextStyle(
                            color: !_isExpense ? Colors.white : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(child: _buildChart(context)),
        ],
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        final settings = Provider.of<SettingsProvider>(context);
        final stats = provider.getCategoryStats(_isExpense);

        if (stats.isEmpty) {
          return Center(
            child: Text(
              'No data available',
              style: TextStyle(color: Colors.grey.shade400),
            ),
          );
        }

        final total = stats.values.fold(0.0, (sum, val) => sum + val);

        return Column(
          children: [
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: stats.entries.map((entry) {
                    final percentage = (entry.value / total) * 100;
                    return PieChartSectionData(
                      color: _getColor(entry.key),
                      value: entry.value,
                      title: '${percentage.toStringAsFixed(0)}%',
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: stats.entries.map((entry) {
                  final currencyFormat = NumberFormat.currency(
                    locale: 'id_ID',
                    symbol: settings.currencySymbol,
                    decimalDigits: 0,
                  );
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow:
                          Theme.of(context).brightness == Brightness.light
                          ? AppTheme.softShadow
                          : [],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getColor(entry.key),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          entry.key,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        Text(
                          currencyFormat.format(entry.value),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getColor(String category) {
    // A simple hash-like mechanism to get stable colors for categories
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    return colors[category.hashCode % colors.length];
  }
}
