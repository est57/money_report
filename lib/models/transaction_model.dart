class TransactionModel {
  final int? id;
  final String title;
  final double amount;
  final bool isExpense;
  final DateTime date;
  final String category;

  TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.isExpense,
    required this.date,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'isExpense': isExpense ? 1 : 0,
      'date': date.toIso8601String(),
      'category': category,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      isExpense: (map['isExpense'] == 1),
      date: DateTime.parse(map['date']),
      category: map['category'],
    );
  }
}
