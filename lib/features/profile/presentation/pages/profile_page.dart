import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../app/bindings/injection_container.dart';
import '../../../../../app/router/route_names.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileCubit>(),
      child: BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is ProfileSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Profile')),
          body: ListView(
            children: [
              const _ProfileHeader(),
              const Divider(height: 1),
              Builder(
                builder: (context) => _SettingsTile(
                  icon: Icons.person_outline,
                  label: 'Edit Profile',
                  onTap: () {
                    context.push('/profile/edit');
                  },
                ),
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
              Builder(
                builder: (context) => _SettingsTile(
                  icon: Icons.logout_outlined,
                  label: 'Sign Out',
                  color: AppColors.error,
                  onTap: () => _showLogoutDialog(context),
                ),
              ),
            ],
          ),
        ),
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
            onPressed: () async {
              await context.read<AuthCubit>().logout();
              if (context.mounted) {
                context.go(RouteNames.login);
              }
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
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          final user = state.user;
          final avatarUrl = user.avatarUrl;
          final displayName = user.displayName;
          final username = user.username;
          final email = user.email;

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.primaryLight,
                      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                      child: avatarUrl == null 
                          ? const Icon(Icons.person, size: 36, color: AppColors.primary)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () async {
                          final picker = ImagePicker();
                          final xFile = await picker.pickImage(source: ImageSource.gallery);
                          if (xFile != null && context.mounted) {
                            context.read<ProfileCubit>().uploadAvatar(File(xFile.path));
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(displayName, style: AppTextStyles.headlineSmall),
                      if (username != null && username.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: username));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Username copied')),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text('@$username', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary)),
                          ),
                        ),
                      Text(email, style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        return const Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(child: CircularProgressIndicator()),
        );
      },
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
