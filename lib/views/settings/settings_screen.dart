import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sageBackground,
      appBar: AppBar(
        title: const Text('Pengaturan', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.sagePrimary),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _buildSectionHeader('Preferensi Aplikasi'),
          _buildSettingsTile(
            icon: Icons.dark_mode_rounded,
            title: 'Tema Gelap',
            trailing: Switch(
              value: false, // Dummy switch
              activeColor: AppColors.sagePrimary,
              onChanged: (val) {},
            ),
          ),
          _buildSettingsTile(
            icon: Icons.notifications_active_rounded,
            title: 'Notifikasi',
            trailing: Switch(
              value: true, // Dummy switch
              activeColor: AppColors.sagePrimary,
              onChanged: (val) {},
            ),
          ),
          const Divider(height: 32),
          _buildSectionHeader('Tentang'),
          _buildSettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'Versi Aplikasi',
            trailing: const Text('v1.0.0', style: TextStyle(color: AppColors.textSecondary)),
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.article_rounded,
            title: 'Syarat & Ketentuan',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.privacy_tip_rounded,
            title: 'Kebijakan Privasi',
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
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Icon(icon, color: AppColors.sagePrimary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}
