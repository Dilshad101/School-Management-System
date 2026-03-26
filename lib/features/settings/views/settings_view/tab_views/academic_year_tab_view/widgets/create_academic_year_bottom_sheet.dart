import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../../../shared/styles/app_styles.dart';
import '../../../../../../../shared/widgets/buttons/gradient_button.dart';

/// Bottom sheet for creating or editing an academic year
class CreateAcademicYearBottomSheet extends StatefulWidget {
  final String? initialName;
  final String? initialStartDate;
  final String? initialEndDate;
  final bool isEditing;

  const CreateAcademicYearBottomSheet({
    super.key,
    this.initialName,
    this.initialStartDate,
    this.initialEndDate,
    this.isEditing = false,
  });

  /// Shows the bottom sheet and returns the result
  static Future<CreateAcademicYearResult?> show(
    BuildContext context, {
    String? initialName,
    String? initialStartDate,
    String? initialEndDate,
    bool isEditing = false,
  }) {
    return showModalBottomSheet<CreateAcademicYearResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CreateAcademicYearBottomSheet(
        initialName: initialName,
        initialStartDate: initialStartDate,
        initialEndDate: initialEndDate,
        isEditing: isEditing,
      ),
    );
  }

  @override
  State<CreateAcademicYearBottomSheet> createState() =>
      _CreateAcademicYearBottomSheetState();
}

class _CreateAcademicYearBottomSheetState
    extends State<CreateAcademicYearBottomSheet> {
  final _nameController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  final _dateFormat = DateFormat('yyyy-MM-dd');
  final _displayFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    if (widget.initialName != null) {
      _nameController.text = widget.initialName!;
    }
    if (widget.initialStartDate != null) {
      _startDate = _parseDate(widget.initialStartDate!);
    }
    if (widget.initialEndDate != null) {
      _endDate = _parseDate(widget.initialEndDate!);
    }
  }

  DateTime? _parseDate(String dateStr) {
    try {
      return _dateFormat.parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
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
                widget.isEditing
                    ? 'Edit Academic Year'
                    : 'Create Academic Year',
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

          // Name Field
          _buildLabel('Name'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _nameController,
            hintText: 'eg: 2025-2026',
          ),
          const SizedBox(height: 16),

          // Start Date Field
          _buildLabel('Start Date'),
          const SizedBox(height: 8),
          _DatePickerField(
            value: _startDate,
            hintText: 'Select start date',
            onTap: () => _pickDate(isStartDate: true),
            displayFormat: _displayFormat,
          ),
          const SizedBox(height: 16),

          // End Date Field
          _buildLabel('End Date'),
          const SizedBox(height: 8),
          _DatePickerField(
            value: _endDate,
            hintText: 'Select end date',
            onTap: () => _pickDate(isStartDate: false),
            displayFormat: _displayFormat,
          ),
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
                  onPressed: _onSubmit,
                  height: 48,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
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

  Future<void> _pickDate({required bool isStartDate}) async {
    final initialDate = isStartDate
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _onSubmit() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a name')));
      return;
    }

    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a start date')),
      );
      return;
    }

    if (_endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an end date')),
      );
      return;
    }

    Navigator.pop(
      context,
      CreateAcademicYearResult(
        name: name,
        startDate: _dateFormat.format(_startDate!),
        endDate: _dateFormat.format(_endDate!),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final DateTime? value;
  final String hintText;
  final VoidCallback onTap;
  final DateFormat displayFormat;

  const _DatePickerField({
    required this.value,
    required this.hintText,
    required this.onTap,
    required this.displayFormat,
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
                value != null ? displayFormat.format(value!) : hintText,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: value != null
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
            Icon(
              Icons.calendar_today_outlined,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Result returned from the Create Academic Year bottom sheet
class CreateAcademicYearResult {
  final String name;
  final String startDate;
  final String endDate;

  CreateAcademicYearResult({
    required this.name,
    required this.startDate,
    required this.endDate,
  });
}
