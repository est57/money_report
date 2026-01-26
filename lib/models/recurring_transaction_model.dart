class RecurringTransactionModel {
  final int? id;
  final String title;
  final double amount;
  final bool isExpense;
  final String category;
  final String frequency; // Currently only 'Monthly' supported
  final DateTime nextDueDate;

  RecurringTransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.isExpense,
    required this.category,
    this.frequency = 'Monthly',
    required this.nextDueDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'isExpense': isExpense ? 1 : 0,
      'category': category,
      'frequency': frequency,
      'nextDueDate': nextDueDate.toIso8601String(),
    };
  }

  factory RecurringTransactionModel.fromMap(Map<String, dynamic> map) {
    return RecurringTransactionModel(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      isExpense: map['isExpense'] == 1,
      category: map['category'],
      frequency: map['frequency'],
      nextDueDate: DateTime.parse(map['nextDueDate']),
    );
  }
}
