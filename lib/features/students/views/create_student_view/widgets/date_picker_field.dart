import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:school_management_system/shared/styles/app_styles.dart';

/// A date picker form field.
class DatePickerField extends StatelessWidget {
  const DatePickerField({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.onChanged,
    this.validator,
    this.firstDate,
    this.lastDate,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });

  final String label;
  final String hint;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final String? Function(DateTime?)? validator;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final AutovalidateMode autovalidateMode;

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? DateTime(now.year - 10, now.month, now.day),
      firstDate: firstDate ?? DateTime(1950),
      lastDate: lastDate ?? now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        FormField<DateTime>(
          initialValue: value,
          validator: validator,
          autovalidateMode: autovalidateMode,
          builder: (FormFieldState<DateTime> state) {
            // Sync the form field value with the widget value
            if (state.value != value) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                state.didChange(value);
              });
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _showDatePicker(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: state.hasError
                            ? AppColors.borderError
                            : AppColors.border,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          color: AppColors.iconDefault,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            value != null ? _formatDate(value!) : hint,
                            style: value != null
                                ? AppTextStyles.bodyMedium
                                : AppTextStyles.hint,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
                if (state.hasError) ...[
                  const SizedBox(height: 8),
                  Text(
                    state.errorText!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.borderError,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}
