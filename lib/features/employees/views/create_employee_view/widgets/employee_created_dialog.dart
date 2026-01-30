import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:school_management_system/shared/styles/app_styles.dart';
import 'package:school_management_system/shared/widgets/buttons/gradient_button.dart';

/// Success dialog shown after employee creation is successful.
class EmployeeCreatedDialog extends StatelessWidget {
  const EmployeeCreatedDialog({
    super.key,
    required this.employeeName,
    required this.employeeId,
    required this.categoryLabel,
    required this.onViewProfile,
    required this.onAddAnother,
    required this.onClose,
  });

  final String employeeName;
  final String employeeId;
  final String categoryLabel;
  final VoidCallback onViewProfile;
  final VoidCallback onAddAnother;
  final VoidCallback onClose;

  /// Shows the success dialog.
  static Future<void> show({
    required BuildContext context,
    required String employeeName,
    required String employeeId,
    required String categoryLabel,
    required VoidCallback onViewProfile,
    required VoidCallback onAddAnother,
    required VoidCallback onClose,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EmployeeCreatedDialog(
        employeeName: employeeName,
        employeeId: employeeId,
        categoryLabel: categoryLabel,
        onViewProfile: onViewProfile,
        onAddAnother: onAddAnother,
        onClose: onClose,
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: employeeId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ID copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine the title based on category
    final title = categoryLabel == 'Teachers'
        ? 'Teacher added successfully'
        : '$categoryLabel added successfully';

    final idLabel = categoryLabel == 'Teachers' ? 'Teacher ID' : 'Employee ID';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              title,
              style: AppTextStyles.heading4.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              'The ${categoryLabel.toLowerCase()} record is now available in the system',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Employee info card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Employee Name
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'name',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          employeeName,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Employee ID
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        idLabel,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            employeeId,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _copyToClipboard(context),
                            child: Icon(
                              Icons.copy_outlined,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // View Profile button
            GradientButton(
              label: 'View Profil',
              onPressed: onViewProfile,
              height: 42,
            ),
            const SizedBox(height: 16),

            // Add Another button
            GestureDetector(
              onTap: onAddAnother,
              child: Text(
                'Add Another ${categoryLabel == 'Teachers' ? 'Teacher' : categoryLabel}',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Close button
            GestureDetector(
              onTap: onClose,
              child: Text(
                'Close',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
