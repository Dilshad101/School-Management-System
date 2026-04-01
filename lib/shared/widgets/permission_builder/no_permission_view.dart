import 'package:flutter/material.dart';

import '../../styles/app_styles.dart';

/// A user-friendly widget displayed when the user lacks permission to access a feature.
class NoPermissionView extends StatelessWidget {
  const NoPermissionView({
    super.key,
    this.title = 'Access Restricted',
    this.message = 'You don\'t have permission to access this feature.',
    this.icon = Icons.lock_outline,
    this.onGoBack,
    this.showGoBackButton = true,
  });

  /// The title displayed at the top.
  final String title;

  /// The message explaining the restriction.
  final String message;

  /// The icon to display.
  final IconData icon;

  /// Callback when the "Go Back" button is pressed.
  /// If null and [showGoBackButton] is true, it will use Navigator.pop.
  final VoidCallback? onGoBack;

  /// Whether to show the "Go Back" button.
  final bool showGoBackButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with background
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 48, color: AppColors.primary),
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  title,
                  style: AppTextStyles.heading3.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Message
                Text(
                  message,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Go Back button
                if (showGoBackButton)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: onGoBack ?? () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Go Back'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
