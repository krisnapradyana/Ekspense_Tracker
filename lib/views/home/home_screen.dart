import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:home_widget/home_widget.dart';
import '../../controllers/budget_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../models/budget_model.dart';
import '../../models/expense_model.dart';
import 'widgets/hero_card.dart';
import 'widgets/custom_bottom_nav.dart';
import '../expense/add_expense_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hasCheckedFirstLaunch = false;

  @override
  void initState() {
    super.initState();
    _checkInitialWidgetClick();
    _listenWidgetClick();
  }

  void _checkInitialWidgetClick() async {
    final Uri? initialUri = await HomeWidget.initiallyLaunchedFromHomeWidget();
    if (initialUri != null) {
      _handleWidgetClick(initialUri);
    }
  }

  void _listenWidgetClick() {
    HomeWidget.widgetClicked.listen(_handleWidgetClick);
  }

  void _handleWidgetClick(Uri? uri) {
    if (uri != null && uri.scheme == 'expensetracker' && uri.host == 'add') {
      _showAddExpenseSheet(context);
    }
  }

  void _showLanguageSelectionDialog(BuildContext context, SettingsController controller) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            controller.getString('firstLaunchTitle'),
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                controller.getString('selectLanguagePrompt'),
                textAlign: TextAlign.center,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              ListTile(
                title: const Text('Bahasa Indonesia'),
                leading: const Icon(Icons.language, color: AppColors.sagePrimary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () {
                  controller.setLanguage('id');
                  controller.completeFirstLaunch();
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                title: const Text('English (US)'),
                leading: const Icon(Icons.language, color: AppColors.sagePrimary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () {
                  controller.setLanguage('en');
                  controller.completeFirstLaunch();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddExpenseSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const AddExpenseSheet(),
    );
  }

  Future<void> _selectDate(BuildContext context, BudgetController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.isAfter(DateTime.now())
          ? DateTime.now()
          : controller.selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        final colorScheme = Theme.of(context).colorScheme;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: colorScheme.copyWith(
              primary: AppColors.sagePrimary,
              onPrimary: Colors.white,
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
    final settingsController = context.watch<SettingsController>();

    if (settingsController.isInitialized && !_hasCheckedFirstLaunch) {
      _hasCheckedFirstLaunch = true;
      if (settingsController.isFirstLaunch) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showLanguageSelectionDialog(context, settingsController);
        });
      }
    }

    final colorScheme = Theme.of(context).colorScheme;

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
          final dateText = isToday ? settingsController.getString('today') : DateFormat('dd MMM yyyy').format(controller.selectedDate);

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
                      '${settingsController.getString('expenses')} $dateText',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Center(
                    child: Text(
                      settingsController.getString('noExpenseDate'),
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
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
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
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
                            category.name,
                            style: TextStyle(color: colorScheme.onSurfaceVariant),
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
