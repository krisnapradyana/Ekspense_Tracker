import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/budget_controller.dart';
import '../../models/budget_model.dart';
import '../../core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'budget_detail_screen.dart';

class GlobalBudgetDetailScreen extends StatelessWidget {
  const GlobalBudgetDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<BudgetController>();
    
    // Get all expenses
    final allExpenses = List.of(controller.expenses);
    
    // Sort expenses by date (newest first)
    allExpenses.sort((a, b) => b.date.compareTo(a.date));

    final percentage = controller.overallPercentageSpent.clamp(0.0, 1.0);
    final color = AppColors.getDynamicColor(percentage);

    return Scaffold(
      backgroundColor: AppColors.sageBackground,
      appBar: AppBar(
        title: const Text('Semua Pengeluaran', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.sagePrimary),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header Card
          Container(
            margin: const EdgeInsets.all(24.0),
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: AppColors.sageSurface,
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
                    const Text('Sisa Budget Total', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                    Text('Total: Rp ${controller.totalAllocated.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Rp ${controller.totalRemaining.toStringAsFixed(0)}',
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
                    value: percentage > 0 ? percentage : 0.0,
                    backgroundColor: AppColors.sageSecondary.withOpacity(0.4),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Terpakai: Rp ${controller.totalSpent.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              ],
            ),
          ),
          
          // History Section
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.sageSurface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
                    child: Text(
                      'Rincian Budget',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: controller.categories.isEmpty
                        ? const Center(
                            child: Text(
                              'Belum ada budget yang dicatat.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8).copyWith(bottom: 24),
                            itemCount: controller.categories.length,
                            itemBuilder: (context, index) {
                              final cat = controller.categories[index];
                              final catPercentage = cat.percentageSpent.clamp(0.0, 1.0);
                              final catColor = AppColors.getDynamicColor(catPercentage);

                              return InkWell(
                                onTap: () {
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
                                          value: catPercentage,
                                          backgroundColor: AppColors.sageSecondary.withOpacity(0.4),
                                          valueColor: AlwaysStoppedAnimation<Color>(catColor),
                                          minHeight: 6,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text('Sisa: Rp ${cat.remaining.toStringAsFixed(0)}', 
                                           style: TextStyle(color: catColor, fontWeight: FontWeight.w600, fontSize: 12)),
                                    ],
                                  ),
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
