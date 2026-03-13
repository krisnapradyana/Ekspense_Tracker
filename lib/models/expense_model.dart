class Expense {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String budgetId;
  final String? receiptImagePath;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.budgetId,
    this.receiptImagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'budgetId': budgetId,
      'receiptImagePath': receiptImagePath,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      title: map['title'],
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date']),
      budgetId: map['budgetId'],
      receiptImagePath: map['receiptImagePath'],
    );
  }
}
