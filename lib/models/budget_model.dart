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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'allocatedAmount': allocatedAmount,
      'spentAmount': spentAmount,
    };
  }

  factory BudgetCategory.fromMap(Map<String, dynamic> map) {
    return BudgetCategory(
      id: map['id'],
      name: map['name'],
      allocatedAmount: (map['allocatedAmount'] as num).toDouble(),
      spentAmount: (map['spentAmount'] as num).toDouble(),
    );
  }
}
