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
}
