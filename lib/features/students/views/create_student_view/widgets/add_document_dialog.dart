import 'dart:io';

import 'package:flutter/material.dart';
import 'package:school_management_system/shared/styles/app_styles.dart';
import 'package:school_management_system/shared/widgets/buttons/gradient_button.dart';

/// Dialog for adding a new document.
class AddDocumentDialog extends StatefulWidget {
  const AddDocumentDialog({
    super.key,
    required this.studentName,
    required this.onPickFile,
    required this.onAdd,
  });

  final String studentName;
  final Future<File?> Function() onPickFile;
  final void Function(String name, File file) onAdd;

  static Future<void> show({
    required BuildContext context,
    required String studentName,
    required Future<File?> Function() onPickFile,
    required void Function(String name, File file) onAdd,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AddDocumentDialog(
        studentName: studentName,
        onPickFile: onPickFile,
        onAdd: onAdd,
      ),
    );
  }

  @override
  State<AddDocumentDialog> createState() => _AddDocumentDialogState();
}

class _AddDocumentDialogState extends State<AddDocumentDialog> {
  final _nameController = TextEditingController();
  File? _selectedFile;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final file = await widget.onPickFile();
    if (file != null) {
      setState(() {
        _selectedFile = file;
        _errorMessage = null;
      });
    }
  }

  void _onAdd() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a document name';
      });
      return;
    }

    if (_selectedFile == null) {
      setState(() {
        _errorMessage = 'Please select a file';
      });
      return;
    }

    widget.onAdd(name, _selectedFile!);
    Navigator.pop(context);
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
            // Title
            Text(
              'Add Documents',
              style: AppTextStyles.heading4.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Enter The Documents Required By ${widget.studentName}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Document name field
            TextFormField(
              controller: _nameController,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Enter Document Name',
                hintStyle: AppTextStyles.hint,
                filled: true,
                fillColor: AppColors.cardBackground,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // File upload area
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withAlpha(50),
                    width: 1.5,
                  ),
                ),
                child: _selectedFile != null
                    ? _buildFileSelected()
                    : _buildUploadPrompt(),
              ),
            ),

            // Error message
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: AppTextStyles.bodySmall.copyWith(color: Colors.red),
              ),
            ],

            const SizedBox(height: 20),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlineButton(
                    label: 'Cancel',
                    onPressed: () => Navigator.pop(context),
                    height: 42,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GradientButton(
                    label: 'Add',
                    onPressed: _onAdd,
                    height: 42,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadPrompt() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.secondary.withAlpha(30),
                AppColors.primary.withAlpha(30),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.upload_file_outlined,
            color: AppColors.primary,
            size: 28,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Click to Upload',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '(Max. File size: 15 MB)',
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildFileSelected() {
    final fileName = _selectedFile!.path.split('/').last;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.green.withAlpha(30),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_outline,
            color: AppColors.green,
            size: 28,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          fileName,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
