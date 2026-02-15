import 'package:flutter/material.dart';
import 'package:school_management_system/shared/styles/app_styles.dart';

import '../../../../../../features/students/blocs/create_student/create_student_state.dart';

/// Step 2 of Create Student flow - Documents.
class DocumentsStep extends StatelessWidget {
  const DocumentsStep({
    super.key,
    required this.formKey,
    required this.documents,
    required this.studentName,
    required this.onPickFile,
    required this.onAddDocument,
    required this.onRemoveDocument,
  });

  final GlobalKey<FormState> formKey;
  final List<DocumentModel> documents;
  final String studentName;
  final Future<void> Function(int index) onPickFile;
  final VoidCallback onAddDocument;
  final void Function(int index) onRemoveDocument;

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
              'Documents ($studentName)',
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
                  onRemove: () => onRemoveDocument(index),
                ),
              );
            }),

            const SizedBox(height: 8),

            // Add document button
            if (documents.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: _AddDocumentButton(onTap: onAddDocument),
              ),
            if (documents.isEmpty) ...[
              const SizedBox(height: 16),

              Center(child: _AddDocumentButton(onTap: onAddDocument)),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// Card widget for displaying a document.
class _DocumentCard extends StatelessWidget {
  const _DocumentCard({
    required this.document,
    required this.onPickFile,
    this.onRemove,
  });

  final DocumentModel document;
  final VoidCallback onPickFile;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
              child: document.hasAnyFile
                  ? _FileSelectedContent(
                      fileName: document.hasFile
                          ? document.fileName
                          : document.name,
                      isExistingUrl:
                          document.hasExistingFile && !document.hasFile,
                      onReplace: onPickFile,
                    )
                  : _UploadContent(onTap: onPickFile),
            ),
            if (onRemove != null)
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(20),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, size: 16, color: Colors.red),
                  ),
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
  const _FileSelectedContent({
    required this.fileName,
    required this.onReplace,
    this.isExistingUrl = false,
  });

  final String fileName;
  final VoidCallback onReplace;
  final bool isExistingUrl;

  @override
  Widget build(BuildContext context) {
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
            isExistingUrl
                ? Icons.cloud_done_outlined
                : Icons.check_circle_outline,
            color: AppColors.green,
            size: 28,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          isExistingUrl ? 'Already uploaded' : fileName,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
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

/// Floating action button to add a new document.
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
              color: AppColors.primary.withAlpha(50),
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
