import 'package:flutter/material.dart';

import '../../../../../../../shared/styles/app_styles.dart';
import '../../../../../../../shared/widgets/buttons/gradient_button.dart';
import '../../../../../models/fee_component_model.dart';

/// Bottom sheet for creating or editing a fee component
class CreateFeeComponentBottomSheet extends StatefulWidget {
  final String? initialName;
  final FeeFrequency? initialFrequency;
  final bool initialIsOptional;
  final bool isEditing;

  const CreateFeeComponentBottomSheet({
    super.key,
    this.initialName,
    this.initialFrequency,
    this.initialIsOptional = false,
    this.isEditing = false,
  });

  /// Shows the bottom sheet and returns the result
  static Future<CreateFeeComponentResult?> show(
    BuildContext context, {
    String? initialName,
    FeeFrequency? initialFrequency,
    bool initialIsOptional = false,
    bool isEditing = false,
  }) {
    return showModalBottomSheet<CreateFeeComponentResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CreateFeeComponentBottomSheet(
        initialName: initialName,
        initialFrequency: initialFrequency,
        initialIsOptional: initialIsOptional,
        isEditing: isEditing,
      ),
    );
  }

  @override
  State<CreateFeeComponentBottomSheet> createState() =>
      _CreateFeeComponentBottomSheetState();
}

class _CreateFeeComponentBottomSheetState
    extends State<CreateFeeComponentBottomSheet> {
  final _nameController = TextEditingController();
  FeeFrequency _selectedFrequency = FeeFrequency.monthly;
  bool _isOptional = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialName != null) {
      _nameController.text = widget.initialName!;
    }
    if (widget.initialFrequency != null) {
      _selectedFrequency = widget.initialFrequency!;
    }
    _isOptional = widget.initialIsOptional;
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
                    ? 'Edit Fee Component'
                    : 'Create Fee Component',
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
          _buildLabel('Enter Name'),
          const SizedBox(height: 8),
          _buildTextField(controller: _nameController, hintText: 'Enter Name'),
          const SizedBox(height: 16),

          // Type Dropdown
          _buildLabel('Type'),
          const SizedBox(height: 8),
          _buildTypeDropdown(),
          const SizedBox(height: 16),

          // Frequency Dropdown
          _buildLabel('Frequency'),
          const SizedBox(height: 8),
          _buildFrequencyDropdown(),
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

  Widget _buildTypeDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<bool>(
          value: _isOptional,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          borderRadius: BorderRadius.circular(12),
          items: [
            DropdownMenuItem(
              value: false,
              child: Text('Mandatory', style: AppTextStyles.bodyMedium),
            ),
            DropdownMenuItem(
              value: true,
              child: Text('Optional', style: AppTextStyles.bodyMedium),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _isOptional = value;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildFrequencyDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<FeeFrequency>(
          value: _selectedFrequency,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          borderRadius: BorderRadius.circular(12),
          items: FeeFrequency.values.map((frequency) {
            return DropdownMenuItem(
              value: frequency,
              child: Text(
                frequency.displayName,
                style: AppTextStyles.bodyMedium,
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedFrequency = value;
              });
            }
          },
        ),
      ),
    );
  }

  void _onSubmit() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a name')));
      return;
    }

    Navigator.pop(
      context,
      CreateFeeComponentResult(
        name: name,
        frequency: _selectedFrequency,
        isOptional: _isOptional,
      ),
    );
  }
}

/// Result returned from the CreateFeeComponentBottomSheet
class CreateFeeComponentResult {
  final String name;
  final FeeFrequency frequency;
  final bool isOptional;

  CreateFeeComponentResult({
    required this.name,
    required this.frequency,
    required this.isOptional,
  });
}
