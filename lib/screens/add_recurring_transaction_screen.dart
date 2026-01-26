import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:hugeicons/hugeicons.dart';
import '../models/recurring_transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/theme.dart';

class AddRecurringTransactionScreen extends StatefulWidget {
  final RecurringTransactionModel? transaction;

  const AddRecurringTransactionScreen({super.key, this.transaction});

  @override
  State<AddRecurringTransactionScreen> createState() =>
      _AddRecurringTransactionScreenState();
}

class _AddRecurringTransactionScreenState
    extends State<AddRecurringTransactionScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isExpense = true;
  String? _selectedCategory;
  dynamic _selectedCategoryIcon;
  final String _frequency = 'Monthly'; // Fixed for V1

  final List<Map<String, dynamic>> _expenseCategories = [
    {'name': 'Food', 'icon': HugeIcons.strokeRoundedRestaurant01},
    {'name': 'Transport', 'icon': HugeIcons.strokeRoundedBus01},
    {'name': 'Shopping', 'icon': HugeIcons.strokeRoundedShoppingBag01},
    {'name': 'Bills', 'icon': HugeIcons.strokeRoundedInvoice01},
    {'name': 'Entertainment', 'icon': HugeIcons.strokeRoundedVideo01},
    {'name': 'Health', 'icon': HugeIcons.strokeRoundedHospital01},
    {'name': 'Education', 'icon': HugeIcons.strokeRoundedMortarboard01},
    {'name': 'Other', 'icon': HugeIcons.strokeRoundedMoreHorizontal},
  ];

  final List<Map<String, dynamic>> _incomeCategories = [
    {'name': 'Salary', 'icon': HugeIcons.strokeRoundedBriefcase01},
    {'name': 'Bonus', 'icon': HugeIcons.strokeRoundedStar},
    {'name': 'Award', 'icon': HugeIcons.strokeRoundedChampion},
    {'name': 'Investment', 'icon': HugeIcons.strokeRoundedChartIncrease},
    {'name': 'Other', 'icon': HugeIcons.strokeRoundedMoreHorizontal},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      final tx = widget.transaction!;
      _titleController.text = tx.title;
      _amountController.text = tx.amount.toString();
      _selectedDate = tx.nextDueDate;
      _isExpense = tx.isExpense;
      _selectedCategory = tx.category;

      final categoryList = _isExpense ? _expenseCategories : _incomeCategories;
      final categoryData = categoryList.firstWhere(
        (element) => element['name'] == _selectedCategory,
        orElse: () => {'icon': HugeIcons.strokeRoundedDashboardSquare01},
      );
      _selectedCategoryIcon = categoryData['icon'];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submitData() {
    if (_amountController.text.isEmpty ||
        _titleController.text.isEmpty ||
        _selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final enteredTitle = _titleController.text;
    final enteredAmount = double.tryParse(_amountController.text);

    if (enteredAmount == null || enteredAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final newTx = RecurringTransactionModel(
      id: widget.transaction?.id,
      title: enteredTitle,
      amount: enteredAmount,
      nextDueDate: _selectedDate,
      isExpense: _isExpense,
      category: _selectedCategory!,
      frequency: _frequency,
    );

    if (widget.transaction != null) {
      Provider.of<TransactionProvider>(
        context,
        listen: false,
      ).updateRecurringTransaction(newTx);
    } else {
      Provider.of<TransactionProvider>(
        context,
        listen: false,
      ).addRecurringTransaction(newTx);
    }
    Navigator.of(context).pop();
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  void _showCategoryModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return _CategorySelectionModal(
          categories: _isExpense ? _expenseCategories : _incomeCategories,
          onCategorySelected: (category) {
            setState(() {
              _selectedCategory = category['name'];
              _selectedCategoryIcon = category['icon'];
            });
            Navigator.pop(ctx);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          widget.transaction != null ? 'Edit Recurring' : 'Add Recurring',
          style: const TextStyle(color: Colors.white),
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          'Enter Amount',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${settings.currencySymbol} ',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            IntrinsicWidth(
                              child: TextField(
                                controller: _amountController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: _isExpense
                                      ? AppTheme.expenseColor
                                      : AppTheme.incomeColor,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '0',
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Type Selector
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _isExpense = true;
                              _selectedCategory = null;
                              _selectedCategoryIcon = null;
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _isExpense
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: _isExpense
                                    ? AppTheme.softShadow
                                    : [],
                              ),
                              child: Center(
                                child: Text(
                                  'Expense',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _isExpense
                                        ? AppTheme.expenseColor
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _isExpense = false;
                              _selectedCategory = null;
                              _selectedCategoryIcon = null;
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_isExpense
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: !_isExpense
                                    ? AppTheme.softShadow
                                    : [],
                              ),
                              child: Center(
                                child: Text(
                                  'Income',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: !_isExpense
                                        ? AppTheme.incomeColor
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Form details
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Subscription Details",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Frequency (Read-only for now)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const HugeIcon(
                                  icon: HugeIcons.strokeRoundedRepeat,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Frequency',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                  const Text(
                                    'Monthly',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Category
                        InkWell(
                          onTap: _showCategoryModal,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: (_selectedCategoryIcon != null)
                                        ? (_isExpense
                                              ? AppTheme.expenseColor
                                                    .withOpacity(0.1)
                                              : AppTheme.incomeColor
                                                    .withOpacity(0.1))
                                        : Colors.grey.shade200,
                                    shape: BoxShape.circle,
                                  ),
                                  child: HugeIcon(
                                    icon:
                                        _selectedCategoryIcon ??
                                        HugeIcons
                                            .strokeRoundedDashboardSquare01,
                                    color: (_selectedCategoryIcon != null)
                                        ? (_isExpense
                                              ? AppTheme.expenseColor
                                              : AppTheme.incomeColor)
                                        : Colors.grey,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Category',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                      Text(
                                        _selectedCategory ?? 'Select Category',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: _selectedCategory != null
                                              ? Colors.black87
                                              : Colors.black45,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedArrowRight01,
                                  color: Colors.grey.shade400,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Start Date
                        InkWell(
                          onTap: _presentDatePicker,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(
                                      0.1,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const HugeIcon(
                                    icon: HugeIcons.strokeRoundedCalendar03,
                                    color: AppTheme.primaryColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Start Date / Next Due',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                      Text(
                                        DateFormat(
                                          'EEEE, dd MMM yyyy',
                                        ).format(_selectedDate),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedArrowDown01,
                                  color: Colors.grey.shade400,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Note (Title)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: TextField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  shape: BoxShape.circle,
                                ),
                                child: const HugeIcon(
                                  icon: HugeIcons.strokeRoundedNote01,
                                  color: Colors.black54,
                                  size: 20,
                                ),
                              ),
                              border: InputBorder.none,
                              labelText: 'Title (e.g. Netflix, Rent)',
                              labelStyle: TextStyle(
                                color: Colors.grey.shade500,
                              ),
                              floatingLabelStyle: const TextStyle(
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Save Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -5),
                  blurRadius: 20,
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: _submitData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Save Recurring',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Reusing same category modal logic but locally defined to avoid tight coupling if moved
class _CategorySelectionModal extends StatefulWidget {
  final List<Map<String, dynamic>> categories;
  final Function(Map<String, dynamic>) onCategorySelected;

  const _CategorySelectionModal({
    required this.categories,
    required this.onCategorySelected,
  });

  @override
  State<_CategorySelectionModal> createState() =>
      _CategorySelectionModalState();
}

class _CategorySelectionModalState extends State<_CategorySelectionModal> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredCategories = widget.categories.where((cat) {
      return (cat['name'] as String).toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
    }).toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SizedBox(
        height: 500,
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Search Category...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: filteredCategories.isEmpty
                  ? const Center(child: Text("No category found"))
                  : ListView.builder(
                      itemCount: filteredCategories.length,
                      itemBuilder: (ctx, index) {
                        final cat = filteredCategories[index];
                        return ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: HugeIcon(
                              icon: cat['icon'],
                              color: Colors.black87,
                              size: 20,
                            ),
                          ),
                          title: Text(cat['name'] as String),
                          onTap: () => widget.onCategorySelected(cat),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
