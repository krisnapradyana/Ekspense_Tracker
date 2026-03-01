import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'budget_list_sheet.dart';
import '../../statistics/statistics_screen.dart';
import '../../settings/settings_screen.dart';

class ExtraMenuSheet extends StatelessWidget {
  const ExtraMenuSheet({super.key});

  void _openSheet(BuildContext context, Widget sheet) {
    Navigator.pop(context); // Tutup menu ini dulu
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.sageSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => sheet,
    );
  }

  void _openScreen(BuildContext context, Widget screen) {
    Navigator.pop(context); // Tutup menu bottom sheet
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Menu Utama',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildMenuItem(
            icon: Icons.account_balance_wallet_rounded,
            title: 'Daftar Budget',
            subtitle: 'Kelola kategori dan alokasi dana',
            onTap: () => _openSheet(context, const BudgetListSheet()),
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            icon: Icons.bar_chart_rounded,
            title: 'Statistik',
            subtitle: 'Analisis grafik pengeluaran',
            onTap: () => _openScreen(context, const StatisticsScreen()),
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            icon: Icons.settings_rounded,
            title: 'Pengaturan',
            subtitle: 'Tentang aplikasi dan preferensi',
            onTap: () => _openScreen(context, const SettingsScreen()),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.sageSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.sageSecondary.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.sageBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.sagePrimary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
