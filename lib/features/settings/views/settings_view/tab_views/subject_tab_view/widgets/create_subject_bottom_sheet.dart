import 'package:flutter/material.dart';

import '../../../../../../../shared/styles/app_styles.dart';
import '../../../../../../../shared/widgets/buttons/gradient_button.dart';

/// Bottom sheet for creating or editing a subject
class CreateSubjectBottomSheet extends StatefulWidget {
  final String? initialName;
  final String? initialCode;
  final bool initialIsLab;
  final bool isEditing;

  const CreateSubjectBottomSheet({
    super.key,
    this.initialName,
    this.initialCode,
    this.initialIsLab = false,
    this.isEditing = false,
  });

  /// Shows the bottom sheet and returns the result
  static Future<CreateSubjectResult?> show(
    BuildContext context, {
    String? initialName,
    String? initialCode,
    bool initialIsLab = false,
    bool isEditing = false,
  }) {
    return showModalBottomSheet<CreateSubjectResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CreateSubjectBottomSheet(
        initialName: initialName,
        initialCode: initialCode,
        initialIsLab: initialIsLab,
        isEditing: isEditing,
      ),
    );
  }

  @override
  State<CreateSubjectBottomSheet> createState() =>
      _CreateSubjectBottomSheetState();
}

class _CreateSubjectBottomSheetState extends State<CreateSubjectBottomSheet> {
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isLab = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialName != null) {
      _nameController.text = widget.initialName!;
    }
    if (widget.initialCode != null) {
      _codeController.text = widget.initialCode!;
    }
    _isLab = widget.initialIsLab;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
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
                widget.isEditing ? 'Edit Subject' : 'Create Subject',
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
          _buildTextField(
            controller: _nameController,
            hintText: 'Enter Name',
          ),
          const SizedBox(height: 16),

          // Code Field
          _buildLabel('Enter Code'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _codeController,
            hintText: 'Enter Code',
          ),
          const SizedBox(height: 16),

          // Lab Included Checkbox
          Row(
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  value: _isLab,
                  onChanged: (value) {
                    setState(() {
                      _isLab = value ?? false;
                    });
                  },
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Lab Included',
                style: AppTextStyles.bodyMedium,
              ),
            ],
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
      style: AppTextStyles.bodyMedium.copyWith(
        fontWeight: FontWeight.w500,
      ),
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

  void _onSubmit() {
    final name = _nameController.text.trim();
    final code = _codeController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name')),
      );
      return;
    }

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a code')),
      );
      return;
    }

    Navigator.pop(
      context,
      CreateSubjectResult(
        name: name,
        code: code,
        isLab: _isLab,
      ),
    );
  }
}

/// Result returned from the Create Subject bottom sheet
class CreateSubjectResult {
  final String name;
  final String code;
  final bool isLab;

  CreateSubjectResult({
    required this.name,
    required this.code,
    required this.isLab,
  });
}
