import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_management_system/core/router/route_paths.dart';
import 'package:school_management_system/core/utils/helpers.dart';
import 'package:school_management_system/features/auth/blocs/auth/auth_bloc.dart';
import 'package:school_management_system/features/auth/blocs/user/user_bloc.dart';
import 'package:school_management_system/shared/styles/app_colors.dart';
import 'package:school_management_system/shared/styles/app_text_styles.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, userState) {
          final user = userState.user;
          final userName = user?.fullName ?? 'User';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header Card
                _ProfileHeaderCard(
                  userName: userName,
                  onTap: () {
                    // TODO: Navigate to profile details
                  },
                ),
                const SizedBox(height: 24),

                // Legal Section
                const _SectionTitle(title: 'Legal'),
                const SizedBox(height: 8),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.description_outlined,
                      title: 'Privacy Policy',
                      onTap: () {
                        // TODO: Open privacy policy
                      },
                    ),
                    const _SettingsDivider(),
                    _SettingsTile(
                      icon: Icons.article_outlined,
                      title: 'Terms & Conditions',
                      onTap: () {
                        // TODO: Open terms & conditions
                      },
                    ),
                    const _SettingsDivider(),
                    _SettingsTile(
                      icon: Icons.info_outline,
                      title: 'About App',
                      onTap: () {
                        // TODO: Open about app
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Account Actions Card
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.delete_outline,
                      title: 'Delete Account',
                      onTap: () {
                        _showDeleteAccountConfirmation(context);
                      },
                    ),
                    const _SettingsDivider(),
                    _SettingsTile(
                      icon: Icons.logout,
                      title: 'Sign Out',
                      iconColor: AppColors.borderError,
                      titleColor: AppColors.borderError,
                      showChevron: false,
                      onTap: () {
                        _showSignOutConfirmation(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Version Info
                Center(
                  child: Text(
                    'Version 1.0.0-dev',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSignOutConfirmation(BuildContext context) {
    Helpers.showWarningBottomSheet(
      context,
      title: 'Sign Out',
      message: 'Are you sure you want to sign out of your account?',
      confirmText: 'Sign Out',
      cancelText: 'Cancel',
      icon: Icons.logout,
      onConfirm: () {
        context.read<AuthBloc>().add(AuthLogoutRequested());
        context.go(Routes.login);
      },
    );
  }

  void _showDeleteAccountConfirmation(BuildContext context) {
    Helpers.showWarningBottomSheet(
      context,
      title: 'Delete Account',
      message:
          'Are you sure you want to delete your account? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      icon: Icons.delete_forever,
      confirmDelaySeconds: 5,
      onConfirm: () {
        // TODO: Implement account deletion
      },
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  final String userName;
  final VoidCallback? onTap;

  const _ProfileHeaderCard({required this.userName, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.person_outline,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'View profile details',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? titleColor;
  final bool showChevron;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.onTap,
    this.iconColor,
    this.titleColor,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: iconColor ?? AppColors.textSecondary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: titleColor ?? AppColors.textPrimary,
                  ),
                ),
              ),
              if (showChevron)
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.border,
      indent: 16,
      endIndent: 16,
    );
  }
}
