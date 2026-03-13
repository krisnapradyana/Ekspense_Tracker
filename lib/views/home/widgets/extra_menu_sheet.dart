import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/settings_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../statistics/statistics_screen.dart';
import '../../settings/settings_screen.dart';

class ExtraMenuSheet extends StatelessWidget {
  const ExtraMenuSheet({super.key});

  void _openScreen(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final settingsController = context.watch<SettingsController>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            settingsController.getString('menu Utama'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildMenuItem(
            context: context,
            icon: Icons.bar_chart_rounded,
            title: settingsController.getString('statistics'),
            subtitle: settingsController.getString('analytics'),
            onTap: () => _openScreen(context, const StatisticsScreen()),
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            context: context,
            icon: Icons.settings_rounded,
            title: settingsController.getString('settings'),
            subtitle: settingsController.getString('aboutPrefs'),
            onTap: () => _openScreen(context, const SettingsScreen()),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.sageSecondary.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.sagePrimary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
