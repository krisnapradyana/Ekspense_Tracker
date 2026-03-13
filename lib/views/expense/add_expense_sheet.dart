import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/budget_controller.dart';
import '../../../controllers/settings_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/expense_model.dart';
import '../home/widgets/budget_list_sheet.dart';

class AddExpenseSheet extends StatefulWidget {
  const AddExpenseSheet({super.key});

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String? _selectedBudgetId;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submitExpense() async {
    if (_titleController.text.isEmpty ||
        _amountController.text.isEmpty ||
        _selectedBudgetId == null) {
      // Validasi sederhana
      return;
    }

    final amount = double.tryParse(_amountController.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) return;

    final newExpense = Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      amount: amount,
      date: DateTime.now(),
      budgetId: _selectedBudgetId!,
    );

    await context.read<BudgetController>().addExpense(newExpense);
    if (mounted) Navigator.pop(context); // Tutup sheet setelah simpan
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<BudgetController>();
    final settingsController = context.watch<SettingsController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Default pemilihan budget pertama kali
    if (_selectedBudgetId == null && controller.categories.isNotEmpty) {
      _selectedBudgetId = controller.categories.first.id;
    }

    if (controller.categories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: AppColors.sageSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              settingsController.getString('noBudgetAddedYet'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              settingsController.getString('addBudgetFirst'),
              style: TextStyle(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Tutup sheet tambah pengeluaran
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  builder: (context) => const BudgetListSheet(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sagePrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                settingsController.getString('addBudget'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.onSurfaceVariant,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                settingsController.getString('close'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      // Padding bawah dinamis agar form tidak tertutup keyboard
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            settingsController.getString('recordExpense'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Dropdown Pilih Budget
          DropdownButtonFormField<String>(
            initialValue: _selectedBudgetId,
            decoration: InputDecoration(
              labelText: settingsController.getString('selectBudgetCategory'),
            ),
            items: controller.categories.map((cat) {
              return DropdownMenuItem(value: cat.id, child: Text(cat.name));
            }).toList(),
            onChanged: (val) {
              setState(() {
                _selectedBudgetId = val;
              });
            },
          ),
          const SizedBox(height: 16),

          // Input Nama Pengeluaran
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: settingsController.getString('expenseNameExample'),
              prefixIcon: const Icon(Icons.description_outlined),
            ),
          ),
          const SizedBox(height: 16),

          // Input Nominal
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: settingsController.getString('amount'),
              prefixIcon: const Icon(Icons.attach_money),
            ),
          ),
          const SizedBox(height: 24),

          // Tombol Simpan
          ElevatedButton(
            onPressed: _submitExpense,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sagePrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              settingsController.getString('saveExpense'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
