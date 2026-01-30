import 'package:flutter/material.dart';
import 'package:school_management_system/shared/styles/app_styles.dart';

import '../../../blocs/create_employee/create_employee_state.dart';

/// Step 2 of Create Employee flow - Documents.
class EmployeeDocumentsStep extends StatelessWidget {
  const EmployeeDocumentsStep({
    super.key,
    required this.formKey,
    required this.documents,
    required this.employeeName,
    required this.onPickFile,
    required this.onAddDocument,
    required this.onRemoveDocument,
    required this.onEditDocument,
  });

  final GlobalKey<FormState> formKey;
  final List<EmployeeDocumentModel> documents;
  final String employeeName;
  final Future<void> Function(int index) onPickFile;
  final VoidCallback onAddDocument;
  final void Function(int index) onRemoveDocument;
  final void Function(int index, String newName) onEditDocument;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Section header
            Text(
              'Documents',
              style: AppTextStyles.heading4.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),

            // Document cards
            ...documents.asMap().entries.map((entry) {
              final index = entry.key;
              final doc = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _DocumentCard(
                  document: doc,
                  onPickFile: () => onPickFile(index),
                  onRemove: documents.length > 1
                      ? () => onRemoveDocument(index)
                      : null,
                  onEdit: () =>
                      _showEditDocumentDialog(context, index, doc.name),
                ),
              );
            }),

            const SizedBox(height: 8),

            // Add document button
            Align(
              alignment: Alignment.centerRight,
              child: _AddDocumentButton(onTap: onAddDocument),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showEditDocumentDialog(
    BuildContext context,
    int index,
    String currentName,
  ) {
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Edit Document Name',
          style: AppTextStyles.heading4.copyWith(fontWeight: FontWeight.w600),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter document name',
            hintStyle: AppTextStyles.hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                onEditDocument(index, newName);
              }
              Navigator.pop(context);
            },
            child: Text(
              'Save',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card widget for displaying a document.
class _DocumentCard extends StatelessWidget {
  const _DocumentCard({
    required this.document,
    required this.onPickFile,
    required this.onEdit,
    this.onRemove,
  });

  final EmployeeDocumentModel document;
  final VoidCallback onPickFile;
  final VoidCallback onEdit;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          document.name,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withAlpha(50),
                  width: 1.5,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              ),
              child: document.hasFile
                  ? _FileSelectedContent(
                      fileName: document.fileName,
                      onReplace: onPickFile,
                    )
                  : _UploadContent(onTap: onPickFile),
            ),
            // Edit and Delete buttons
            Positioned(
              top: 8,
              right: 8,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Edit button
                  GestureDetector(
                    onTap: onEdit,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.green.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: AppColors.green,
                      ),
                    ),
                  ),
                  if (onRemove != null) ...[
                    const SizedBox(width: 8),
                    // Delete button
                    GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red.withAlpha(20),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.delete_outline,
                          size: 16,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Content shown when no file is selected.
class _UploadContent extends StatelessWidget {
  const _UploadContent({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
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
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Content shown when a file is selected.
class _FileSelectedContent extends StatelessWidget {
  const _FileSelectedContent({required this.fileName, required this.onReplace});

  final String fileName;
  final VoidCallback onReplace;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // File icon
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.green.withAlpha(20),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.insert_drive_file_outlined,
            color: AppColors.green,
            size: 28,
          ),
        ),
        const SizedBox(height: 12),

        // File name
        Text(
          fileName,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),

        // Replace button
        GestureDetector(
          onTap: onReplace,
          child: Text(
            'Replace file',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

/// Add document button widget.
class _AddDocumentButton extends StatelessWidget {
  const _AddDocumentButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(40),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 24),
      ),
    );
  }
}
