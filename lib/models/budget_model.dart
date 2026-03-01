class BudgetCategory {
  final String id;
  final String name;
  final double allocatedAmount;
  double spentAmount;

  BudgetCategory({
    required this.id,
    required this.name,
    required this.allocatedAmount,
    this.spentAmount = 0.0,
  });

  double get remaining => allocatedAmount - spentAmount;
  double get percentageSpent => allocatedAmount == 0 ? 0 : spentAmount / allocatedAmount;
}
