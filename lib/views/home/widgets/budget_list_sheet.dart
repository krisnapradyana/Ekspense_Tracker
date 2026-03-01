import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/budget_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/budget_model.dart';

import '../budget_detail_screen.dart';

class BudgetListSheet extends StatefulWidget {
  const BudgetListSheet({super.key});

  @override
  State<BudgetListSheet> createState() => _BudgetListSheetState();
}

class _BudgetListSheetState extends State<BudgetListSheet> {
  final _budgetNameController = TextEditingController();
  final _budgetAmountController = TextEditingController();

  @override
  void dispose() {
    _budgetNameController.dispose();
    _budgetAmountController.dispose();
    super.dispose();
  }

  void _addBudget() {
    if (_budgetNameController.text.isEmpty || _budgetAmountController.text.isEmpty) return;

    final amount = double.tryParse(_budgetAmountController.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) return;

    context.read<BudgetController>().addBudgetCategory(
      _budgetNameController.text,
      amount,
    );

    _budgetNameController.clear();
    _budgetAmountController.clear();
    
    // Menutup dialog input tapi tetap di bottom sheet
    Navigator.pop(context);
  }

  void _showAddBudgetDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Budget Baru'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _budgetNameController,
                decoration: const InputDecoration(labelText: 'Nama Budget'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _budgetAmountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Alokasi Dana (Rp)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: _addBudget,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sagePrimary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _showEditBudgetDialog(BudgetCategory cat) {
    final editNameController = TextEditingController(text: cat.name);
    final editAmountController = TextEditingController(text: cat.allocatedAmount.toStringAsFixed(0));
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Budget'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: editNameController,
                decoration: const InputDecoration(labelText: 'Nama Budget'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: editAmountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Alokasi Dana (Rp)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (editNameController.text.isEmpty || editAmountController.text.isEmpty) return;
                final amount = double.tryParse(editAmountController.text.replaceAll(',', ''));
                if (amount != null && amount > 0) {
                  context.read<BudgetController>().updateBudgetCategory(cat.id, editNameController.text, amount);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sagePrimary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, BudgetCategory cat) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Budget'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Text('Apakah Anda yakin ingin menghapus budget "${cat.name}"? Semua pengeluaran terkait juga akan dihapus.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: AppColors.textPrimary)),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<BudgetController>().deleteBudgetCategory(cat.id);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warningRed,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<BudgetController>();
    
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7, // Maksimal 70% tinggi layar
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daftar Budget',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              IconButton(
                onPressed: _showAddBudgetDialog,
                icon: const Icon(Icons.add_circle, color: AppColors.sagePrimary, size: 28),
              )
            ],
          ),
          const Divider(height: 24),
          Expanded(
            child: controller.categories.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada budget.\nSilakan tambah budget baru.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.builder(
              shrinkWrap: true,
              itemCount: controller.categories.length,
              itemBuilder: (context, index) {
                final cat = controller.categories[index];
                final percentage = cat.percentageSpent.clamp(0.0, 1.0);
                final color = AppColors.getDynamicColor(percentage);

                return InkWell(
                  onTap: () {
                    // Close the bottom sheet first
                    Navigator.pop(context);
                    // Navigate to the detail screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BudgetDetailScreen(category: cat),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.sageSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.sageSecondary.withOpacity(0.3)),
                    ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              cat.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text('Rp ${cat.allocatedAmount.toStringAsFixed(0)}', 
                               style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentage,
                          backgroundColor: AppColors.sageSecondary.withOpacity(0.4),
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Sisa: Rp ${cat.remaining.toStringAsFixed(0)}', 
                               style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
                          Row(
                            children: [
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.edit, size: 20, color: AppColors.sagePrimary),
                                onPressed: () => _showEditBudgetDialog(cat),
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.delete, size: 20, color: AppColors.warningRed),
                                onPressed: () => _confirmDelete(context, cat),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
