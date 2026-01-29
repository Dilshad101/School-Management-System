import 'package:flutter/material.dart';
import 'package:school_management_system/shared/styles/app_styles.dart';
import 'package:school_management_system/shared/widgets/buttons/gradient_button.dart';

/// Success dialog shown after class creation is successful.
class ClassCreatedDialog extends StatelessWidget {
  const ClassCreatedDialog({
    super.key,
    required this.className,
    required this.classTeacher,
    required this.onViewClass,
    required this.onAddAnother,
    required this.onClose,
  });

  final String className;
  final String classTeacher;
  final VoidCallback onViewClass;
  final VoidCallback onAddAnother;
  final VoidCallback onClose;

  /// Shows the success dialog.
  static Future<void> show({
    required BuildContext context,
    required String className,
    required String classTeacher,
    required VoidCallback onViewClass,
    required VoidCallback onAddAnother,
    required VoidCallback onClose,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ClassCreatedDialog(
        className: className,
        classTeacher: classTeacher,
        onViewClass: onViewClass,
        onAddAnother: onAddAnother,
        onClose: onClose,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              'Class added successfully',
              style: AppTextStyles.heading4.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              'The Class record is now available in the system',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Class info card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Class
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Class',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        className,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Class Teacher
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Class Teacher',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        classTeacher,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // View Class button
            GradientButton(
              label: 'View Class',
              onPressed: onViewClass,
              height: 42,
            ),
            const SizedBox(height: 16),

            // Add Another Class button
            GestureDetector(
              onTap: onAddAnother,
              child: Text(
                'Add Another Class',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Close button
            GestureDetector(
              onTap: onClose,
              child: Text(
                'Close',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
