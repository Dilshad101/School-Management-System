import 'package:flutter/material.dart';

import '../../../../../../../shared/styles/app_styles.dart';
import '../../../../../../../shared/widgets/buttons/gradient_button.dart';

/// Bottom sheet for creating or editing a period
class CreatePeriodBottomSheet extends StatefulWidget {
  final String? initialStartTime;
  final String? initialEndTime;
  final int? initialOrder;
  final bool isEditing;

  const CreatePeriodBottomSheet({
    super.key,
    this.initialStartTime,
    this.initialEndTime,
    this.initialOrder,
    this.isEditing = false,
  });

  /// Shows the bottom sheet and returns the result
  static Future<CreatePeriodResult?> show(
    BuildContext context, {
    String? initialStartTime,
    String? initialEndTime,
    int? initialOrder,
    bool isEditing = false,
  }) {
    return showModalBottomSheet<CreatePeriodResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CreatePeriodBottomSheet(
        initialStartTime: initialStartTime,
        initialEndTime: initialEndTime,
        initialOrder: initialOrder,
        isEditing: isEditing,
      ),
    );
  }

  @override
  State<CreatePeriodBottomSheet> createState() =>
      _CreatePeriodBottomSheetState();
}

class _CreatePeriodBottomSheetState extends State<CreatePeriodBottomSheet> {
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final _orderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialOrder != null) {
      _orderController.text = widget.initialOrder.toString();
    }
    // Parse initial times if editing
    if (widget.initialStartTime != null) {
      _startTime = _parseTimeString(widget.initialStartTime!);
    }
    if (widget.initialEndTime != null) {
      _endTime = _parseTimeString(widget.initialEndTime!);
    }
  }

  /// Parses time string in "HH:mm:ss" or "HH:mm" format to TimeOfDay
  TimeOfDay? _parseTimeString(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (_) {}
    return null;
  }

  @override
  void dispose() {
    _orderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Spacer(),
              Text(
                widget.isEditing ? 'Edit Period' : 'Create Period',
                style: AppTextStyles.heading4,
              ),
              const Spacer(),
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(20),
                child: const Icon(Icons.close, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Start Time
          _buildLabel('Start time', isRequired: true),
          const SizedBox(height: 8),
          _TimePickerField(
            value: _startTime,
            hintText: '--:-- --',
            onTap: () => _pickTime(isStartTime: true),
          ),
          const SizedBox(height: 16),

          // End Time
          _buildLabel('End time', isRequired: true),
          const SizedBox(height: 8),
          _TimePickerField(
            value: _endTime,
            hintText: '--:-- --',
            onTap: () => _pickTime(isStartTime: false),
          ),
          const SizedBox(height: 16),

          // Enter Order
          _buildLabel('Enter Order'),
          const SizedBox(height: 8),
          _buildOrderField(),
          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GradientButton(
                  label: widget.isEditing ? 'Update' : 'Add',
                  onPressed: _onAdd,
                  height: 48,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
        children: isRequired
            ? [
                TextSpan(
                  text: '*',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ]
            : null,
      ),
    );
  }

  Widget _buildOrderField() {
    return TextField(
      controller: _orderController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: 'Enter order',
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  Future<void> _pickTime({required bool isStartTime}) async {
    final initialTime = isStartTime
        ? (_startTime ?? TimeOfDay.now())
        : (_endTime ?? TimeOfDay.now());

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _onAdd() {
    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end time')),
      );
      return;
    }

    final order = int.tryParse(_orderController.text);

    Navigator.pop(
      context,
      CreatePeriodResult(
        startTime: _formatTime24Hr(_startTime!),
        endTime: _formatTime24Hr(_endTime!),
        order: order,
      ),
    );
  }

  /// Formats TimeOfDay to 24-hour format "HH:mm" for API payload
  String _formatTime24Hr(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _TimePickerField extends StatelessWidget {
  final TimeOfDay? value;
  final String hintText;
  final VoidCallback onTap;

  const _TimePickerField({
    required this.value,
    required this.hintText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value != null ? _formatTime(value!) : hintText,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: value != null
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
            Icon(
              Icons.access_time_outlined,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}

/// Result returned from the Create Period bottom sheet
class CreatePeriodResult {
  final String startTime;
  final String endTime;
  final int? order;

  CreatePeriodResult({
    required this.startTime,
    required this.endTime,
    this.order,
  });
}
