import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:open_file/open_file.dart';
import '../providers/transaction_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/theme.dart';
import '../utils/pdf_generator.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _selectedFilter = 'All'; // 'All', 'Income', 'Expense'

  void _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.brightness == Brightness.dark
                ? ColorScheme.dark(
                    primary: theme.primaryColor,
                    onPrimary: Colors.white,
                    onSurface: Colors.white,
                    surface: theme.scaffoldBackgroundColor,
                  )
                : ColorScheme.light(
                    primary: theme.primaryColor,
                    onPrimary: Colors.white,
                    onSurface: Colors.black,
                  ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> _exportPdf() async {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    // Re-fetching ALL for the period for the PDF report.
    final allTransactionsInPeriod = provider.getFilteredTransactions(
      _startDate,
      _endDate,
      'All',
    );

    double totalIncome = 0;
    double totalExpense = 0;
    for (var tx in allTransactionsInPeriod) {
      if (tx.isExpense) {
        totalExpense += tx.amount;
      } else {
        totalIncome += tx.amount;
      }
    }

    try {
      final file = await PdfGenerator.generateReport(
        transactions: allTransactionsInPeriod,
        startDate: _startDate,
        endDate: _endDate,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        currencySymbol: settings.currencySymbol,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report saved successfully! Opening...')),
      );

      await OpenFile.open(file.path);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to export PDF: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);
    final filteredTransactions = provider.getFilteredTransactions(
      _startDate,
      _endDate,
      _selectedFilter,
    );

    final totalAmount = filteredTransactions.fold(0.0, (sum, tx) {
      if (_selectedFilter == 'All') {
        return sum + (tx.isExpense ? -tx.amount : tx.amount);
      }
      return sum + tx.amount;
    });

    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: settings.currencySymbol,
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: const Text(
          'Transaction Report',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
            // borderRadius removed
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedFile01,
              color: Colors.white,
            ),
            onPressed: _exportPdf,
            tooltip: 'Export PDF',
          ),
          IconButton(
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedCalendar03,
              color: Colors.white,
            ),
            onPressed: _pickDateRange,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips & Date Display
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).cardColor,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${DateFormat('dd MMM').format(_startDate)} - ${DateFormat('dd MMM yyyy').format(_endDate)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      currencyFormat.format(totalAmount),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _selectedFilter == 'Expense'
                            ? AppTheme.expenseColor
                            : _selectedFilter == 'Income'
                            ? AppTheme.incomeColor
                            : Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildFilterChip('All'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Income'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Expense'),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: filteredTransactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedSearch01,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No transactions found',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final tx = filteredTransactions[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow:
                              Theme.of(context).brightness == Brightness.light
                              ? AppTheme.softShadow
                              : [],
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
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
                              size: 20,
                            ),
                          ),
                          title: Text(
                            tx.title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${DateFormat('dd MMM').format(tx.date)} • ${tx.category}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          trailing: Text(
                            currencyFormat.format(tx.amount),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: tx.isExpense
                                  ? AppTheme.expenseColor
                                  : AppTheme.incomeColor,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilter = label;
          });
        }
      },
      selectedColor: AppTheme.primaryColor,
      labelStyle: TextStyle(
        color: isSelected
            ? Colors.white
            : Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade300
            : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade900
          : Colors.grey.shade100,
      showCheckmark: false,
    );
  }
}
