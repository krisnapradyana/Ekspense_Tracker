import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/budget_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../models/budget_model.dart';
import '../../models/expense_model.dart';
import '../../core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class BudgetDetailScreen extends StatefulWidget {
  final BudgetCategory category;

  const BudgetDetailScreen({super.key, required this.category});

  @override
  State<BudgetDetailScreen> createState() => _BudgetDetailScreenState();
}

class _BudgetDetailScreenState extends State<BudgetDetailScreen> {

  void _showEditExpenseDialog(BuildContext context, BudgetController controller, Expense expense, SettingsController settings) {
    final titleController = TextEditingController(text: expense.title);
    final amountController = TextEditingController(text: expense.amount.toStringAsFixed(0));
    String selectedBudgetId = expense.budgetId;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(settings.getString('editExpense'), style: const TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedBudgetId,
                    decoration: InputDecoration(
                      labelText: settings.getString('selectBudgetCategory'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: controller.categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat.id,
                        child: Text(cat.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          selectedBudgetId = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: settings.getString('expenseName'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: settings.getString('amount'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(settings.getString('cancel'), style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(amountController.text.replaceAll(',', ''));
                    if (titleController.text.isNotEmpty && amount != null && amount > 0) {
                      final updatedExpense = Expense(
                        id: expense.id,
                        title: titleController.text,
                        amount: amount,
                        date: expense.date,
                        budgetId: selectedBudgetId,
                      );
                      controller.updateExpense(expense.id, updatedExpense);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sagePrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(settings.getString('save')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteExpense(BuildContext context, BudgetController controller, String expenseId, SettingsController settings) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(settings.getString('deleteExpenseTitle'), style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          settings.getString('deleteExpenseConfirm'),
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(settings.getString('cancel'), style: TextStyle(color: colorScheme.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteExpense(expenseId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warningRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(settings.getString('delete')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<BudgetController>();
    final settingsController = context.watch<SettingsController>();
    final colorScheme = Theme.of(context).colorScheme;

    // Get all expenses for this specific budget
    final categoryExpenses = controller.expenses.where((e) => e.budgetId == widget.category.id).toList();

    // Sort expenses by date (newest first)
    categoryExpenses.sort((a, b) => b.date.compareTo(a.date));

    // Pastikan UI terupdate secara reaktif dengan sisa budget valid
    final currentCategory = controller.categories.firstWhere(
      (c) => c.id == widget.category.id,
      orElse: () => widget.category,
    );

    final percentage = currentCategory.percentageSpent.clamp(0.0, 1.0);
    final color = AppColors.getDynamicColor(percentage);

    return Scaffold(
      appBar: AppBar(
        title: Text(currentCategory.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header Card
          Container(
            margin: const EdgeInsets.all(24.0),
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(24.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(settingsController.getString('remainingBudget'), style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14)),
                    Text('${settingsController.getString('total')} ${currentCategory.allocatedAmount.toStringAsFixed(0)}', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Rp ${currentCategory.remaining.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: color,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: AppColors.sageSecondary.withOpacity(0.4),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Text('${settingsController.getString('spent')} ${currentCategory.spentAmount.toStringAsFixed(0)}', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14)),
              ],
            ),
          ),
          
          // History Section
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    child: Text(
                      settingsController.getString('expenseHistory'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: categoryExpenses.isEmpty
                        ? Center(
                            child: Text(
                              settingsController.getString('noExpenseCategory'),
                              textAlign: TextAlign.center,
                              style: TextStyle(color: colorScheme.onSurfaceVariant),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 24),
                            itemCount: categoryExpenses.length,
                            itemBuilder: (context, index) {
                              final expense = categoryExpenses[index];
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                  child: const Icon(Icons.receipt_long, color: AppColors.sagePrimary),
                                ),
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        expense.title,
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      '- Rp ${expense.amount.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        color: AppColors.warningRed,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      DateFormat('dd MMM yyyy, HH:mm').format(expense.date),
                                      style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          constraints: const BoxConstraints(),
                                          padding: EdgeInsets.zero,
                                          icon: const Icon(Icons.edit, size: 18, color: AppColors.sagePrimary),
                                          onPressed: () {
                                            _showEditExpenseDialog(context, controller, expense, settingsController);
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          constraints: const BoxConstraints(),
                                          padding: EdgeInsets.zero,
                                          icon: const Icon(Icons.delete, size: 18, color: AppColors.warningRed),
                                          onPressed: () {
                                            _confirmDeleteExpense(context, controller, expense.id, settingsController);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
