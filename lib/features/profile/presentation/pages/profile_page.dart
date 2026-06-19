import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/route_names.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        children: [
          const _ProfileHeader(),
          const Divider(height: 1),
          _SettingsTile(
            icon: Icons.person_outline,
            label: 'Edit Profile',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            label: 'Notification Preferences',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.currency_exchange_outlined,
            label: 'Default Currency',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.security_outlined,
            label: 'Security',
            onTap: () {},
          ),
          const Divider(height: 1),
          _SettingsTile(
            icon: Icons.logout_outlined,
            label: 'Sign Out',
            color: AppColors.error,
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              context.read<AuthCubit>().logout();
              context.go(RouteNames.login);
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.primaryLight,
            child: const Icon(Icons.person, size: 36, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your Name', style: AppTextStyles.headlineSmall),
              Text('your@email.com', style: AppTextStyles.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.icon, required this.label, required this.onTap, this.color});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.textPrimary;
    return ListTile(
      leading: Icon(icon, color: effectiveColor),
      title: Text(label, style: AppTextStyles.bodyMedium.copyWith(color: effectiveColor)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textDisabled),
      onTap: onTap,
    );
  }
}
