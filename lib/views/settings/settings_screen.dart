import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/settings_controller.dart';
import '../../core/theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = context.watch<SettingsController>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          settingsController.getString('settings'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _buildSectionHeader(settingsController.getString('generalSettings')),
          _buildSettingsTile(
            context: context,
            icon: Icons.language_rounded,
            title: settingsController.getString('language'),
            trailing: DropdownButton<String>(
              value: settingsController.currentLanguage,
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.sagePrimary),
              dropdownColor: colorScheme.surface,
              items: [
                DropdownMenuItem(
                  value: 'id',
                  child: Text('Indonesia', style: TextStyle(color: colorScheme.onSurface)),
                ),
                DropdownMenuItem(
                  value: 'en',
                  child: Text('English (US)', style: TextStyle(color: colorScheme.onSurface)),
                ),
              ],
              onChanged: (val) {
                if (val != null) {
                  settingsController.setLanguage(val);
                }
              },
            ),
          ),
          _buildSettingsTile(
            context: context,
            icon: Icons.dark_mode_rounded,
            title: settingsController.getString('darkTheme'),
            trailing: Switch(
              value: settingsController.isDarkMode,
              activeThumbColor: AppColors.sagePrimary,
              onChanged: (val) {
                settingsController.toggleDarkMode(val);
              },
            ),
          ),
          _buildSettingsTile(
            context: context,
            icon: Icons.notifications_active_rounded,
            title: settingsController.getString('notifications'),
            trailing: Switch(
              value: true,
              activeThumbColor: AppColors.sagePrimary,
              onChanged: (val) {},
            ),
          ),
          const Divider(height: 32),
          _buildSectionHeader(settingsController.getString('about')),
          _buildSettingsTile(
            context: context,
            icon: Icons.info_outline_rounded,
            title: settingsController.getString('appVersion'),
            trailing: Text(
              'v1.0.0',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            onTap: () {},
          ),
          _buildSettingsTile(
            context: context,
            icon: Icons.article_rounded,
            title: settingsController.getString('termsConditions'),
            onTap: () {},
          ),
          _buildSettingsTile(
            context: context,
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
    required BuildContext context,
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Icon(icon, color: AppColors.sagePrimary),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.onSurface,
        ),
      ),
      trailing: trailing ??
          Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
      onTap: onTap,
    );
  }
}
