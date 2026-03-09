import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/settings_controller.dart';
import '../../core/theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = context.watch<SettingsController>();
    final isDark = settingsController.isDarkMode;

    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      appBar: AppBar(
        title: Text(settingsController.getString('settings'), style: TextStyle(color: AppColors.tp(isDark), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.sagePrimary),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _buildSectionHeader(settingsController.getString('generalSettings')),
          _buildSettingsTile(
            isDark: isDark,
            icon: Icons.language_rounded,
            title: settingsController.getString('language'),
            trailing: DropdownButton<String>(
              value: settingsController.currentLanguage,
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.sagePrimary),
              dropdownColor: AppColors.surface(isDark),
              items: [
                DropdownMenuItem(value: 'id', child: Text('Indonesia', style: TextStyle(color: AppColors.tp(isDark)))),
                DropdownMenuItem(value: 'en', child: Text('English (US)', style: TextStyle(color: AppColors.tp(isDark)))),
              ],
              onChanged: (val) {
                if (val != null) {
                  settingsController.setLanguage(val);
                }
              },
            ),
          ),
          _buildSettingsTile(
            isDark: isDark,
            icon: Icons.dark_mode_rounded,
            title: settingsController.getString('darkTheme'),
            trailing: Switch(
              value: settingsController.isDarkMode,
              activeColor: AppColors.sagePrimary,
              onChanged: (val) {
                settingsController.toggleDarkMode(val);
              },
            ),
          ),
          _buildSettingsTile(
            isDark: isDark,
            icon: Icons.notifications_active_rounded,
            title: settingsController.getString('notifications'),
            trailing: Switch(
              value: true,
              activeColor: AppColors.sagePrimary,
              onChanged: (val) {},
            ),
          ),
          const Divider(height: 32),
          _buildSectionHeader(settingsController.getString('about')),
          _buildSettingsTile(
            isDark: isDark,
            icon: Icons.info_outline_rounded,
            title: settingsController.getString('appVersion'),
            trailing: Text('v1.0.0', style: TextStyle(color: AppColors.ts(isDark))),
            onTap: () {},
          ),
          _buildSettingsTile(
            isDark: isDark,
            icon: Icons.article_rounded,
            title: settingsController.getString('termsConditions'),
            onTap: () {},
          ),
          _buildSettingsTile(
            isDark: isDark,
            icon: Icons.privacy_tip_rounded,
            title: settingsController.getString('privacyPolicy'),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 8, top: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.sagePrimary,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required bool isDark,
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Icon(icon, color: AppColors.sagePrimary),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.tp(isDark))),
      trailing: trailing ?? Icon(Icons.chevron_right_rounded, color: AppColors.ts(isDark)),
      onTap: onTap,
    );
  }
}
