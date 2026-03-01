import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/budget_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../global_budget_detail_screen.dart';

/// Hero Card yang menampilkan total sisa budget dan persentase penggunaan.
class HeroCard extends StatelessWidget {
  const HeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetController>(
      builder: (context, controller, child) {
        final percentage = controller.overallPercentageSpent;
        // Mendapatkan warna dinamis: jika persentase tinggi, warna berubah menuju merah
        final dynamicColor = AppColors.getDynamicColor(percentage);

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GlobalBudgetDetailScreen()),
            );
          },
          borderRadius: BorderRadius.circular(28.0),
          child: Container(
            height: 180, // Tinggi tetap (fixed) agar tidak terpengaruh rotasi landscape
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: dynamicColor,
              borderRadius: BorderRadius.circular(28.0), // Sudut bulat Material 3
              boxShadow: [
                BoxShadow(
                  color: dynamicColor.withOpacity(0.4), // Perbaikan withOpacity untuk kompatibilitas
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Sisa Budget',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp ${controller.totalRemaining.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Bar Indikator Budget
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: percentage > 0 ? percentage : 0.0,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Terpakai: Rp ${controller.totalSpent.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      'Total: Rp ${controller.totalAllocated.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
