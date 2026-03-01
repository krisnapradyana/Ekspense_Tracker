import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/budget_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../models/budget_model.dart';
import '../../models/expense_model.dart'; // import ditambahkan
import 'widgets/hero_card.dart';
import 'widgets/custom_bottom_nav.dart';
import '../expense/add_expense_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  void _showAddExpenseSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.sageSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const AddExpenseSheet(),
    );
  }

  Future<void> _selectDate(BuildContext context, BudgetController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.sagePrimary, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: AppColors.textPrimary, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.sagePrimary, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != controller.selectedDate) {
      controller.updateSelectedDate(picked);
    }
  }

  void _showEditExpenseDialog(BuildContext context, BudgetController controller, Expense expense) {
    final titleController = TextEditingController(text: expense.title);
    final amountController = TextEditingController(text: expense.amount.toStringAsFixed(0));
    String selectedBudgetId = expense.budgetId;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.sageSurface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Edit Pengeluaran', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedBudgetId,
                    decoration: InputDecoration(
                      labelText: 'Pilih Kategori Budget',
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
                      labelText: 'Nama Pengeluaran',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Nominal (Rp)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(amountController.text.replaceAll(',', ''));
                    if (titleController.text.isNotEmpty && amount != null && amount > 0) {
                      final updatedExpense = Expense(
                        id: expense.id,
                        title: titleController.text,
                        amount: amount,
                        date: expense.date, // Pertahankan tanggal asli
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
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteExpense(BuildContext context, BudgetController controller, String expenseId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.sageSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Pengeluaran?', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        content: const Text(
          'Apakah Anda yakin ingin menghapus pengeluaran ini?\n\nDana akan dikembalikan ke sisa budget kategori.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
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
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Icon(
          Icons.account_balance_wallet_rounded,
          color: AppColors.sagePrimary,
          size: 32,
        ),
        centerTitle: true,
      ),
      body: Consumer<BudgetController>(
        builder: (context, controller, child) {
          final filteredExpenses = controller.dateFilteredExpenses;
          final isToday = controller.selectedDate.year == DateTime.now().year && 
                          controller.selectedDate.month == DateTime.now().month && 
                          controller.selectedDate.day == DateTime.now().day;
          final dateText = isToday ? 'Hari Ini' : DateFormat('dd MMM yyyy').format(controller.selectedDate);

          return ListView(
            padding: const EdgeInsets.only(bottom: 100), // Padding ekstra agar list tidak tertutup bottom nav
            children: [
              const HeroCard(),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pengeluaran $dateText',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _selectDate(context, controller),
                      icon: const Icon(Icons.calendar_today_rounded, size: 18),
                      // Mengamankan format tanggal agar tidak error null check
                      label: Text(DateFormat('dd MMM').format(controller.selectedDate)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.sagePrimary,
                        side: const BorderSide(color: AppColors.sagePrimary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (filteredExpenses.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Center(
                    child: Text(
                      'Belum ada pengeluaran di tanggal ini.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                )
              else
                ...filteredExpenses.map((expense) {
                  // Mencari nama kategori berdasarkan budgetId
                  final category = controller.categories.firstWhere(
                    (c) => c.id == expense.budgetId,
                    orElse: () => controller.categories.isNotEmpty 
                        ? controller.categories.first 
                        : BudgetCategory(id: 'unknown', name: 'Unknown', allocatedAmount: 0), // fallback
                  );
                  
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                    decoration: BoxDecoration(
                      color: AppColors.sageSurface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.sageBackground,
                        child: const Icon(Icons.receipt_long, color: AppColors.sagePrimary),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              expense.title,
                              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
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
                            category.name,
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.edit, size: 18, color: AppColors.sagePrimary),
                                onPressed: () {
                                  _showEditExpenseDialog(context, controller, expense);
                                },
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.delete, size: 18, color: AppColors.warningRed),
                                onPressed: () {
                                  _confirmDeleteExpense(context, controller, expense.id);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseSheet(context),
        backgroundColor: AppColors.sagePrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // Membuat tombol FAB lingkaran penuh (Material 3 style)
        ),
        child: Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.sagePrimary,
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(),
    );
  }
}
