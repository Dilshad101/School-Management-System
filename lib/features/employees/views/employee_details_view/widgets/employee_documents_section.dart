import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../shared/styles/app_styles.dart';
import '../../../models/employee_model.dart';

/// Section showing employee documents with upload and download options.
class EmployeeDocumentsSection extends StatelessWidget {
  const EmployeeDocumentsSection({
    super.key,
    required this.documents,
    this.onUpload,
  });

  final List<EmployeeDocumentApiModel> documents;
  final VoidCallback? onUpload;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with upload button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Documents',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton.icon(
              onPressed: onUpload,
              icon: Icon(
                Icons.upload_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              label: Text(
                'Upload',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Documents list
        if (documents.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Text(
                'No documents uploaded',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          ...documents.map((doc) => _DocumentTile(document: doc)),
      ],
    );
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({required this.document});

  final EmployeeDocumentApiModel document;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Document icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_getDocumentIcon(), color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          // Document name
          Expanded(
            child: Text(
              document.documentName ?? 'Document',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Download button
          IconButton(
            onPressed: () => _downloadDocument(context),
            icon: Icon(
              Icons.download_rounded,
              color: AppColors.textSecondary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDocumentIcon() {
    final fileName = document.documentFile?.toLowerCase() ?? '';
    if (fileName.contains('.pdf')) {
      return Icons.picture_as_pdf_rounded;
    } else if (fileName.contains('.doc') || fileName.contains('.docx')) {
      return Icons.description_rounded;
    } else if (fileName.contains('.jpg') ||
        fileName.contains('.jpeg') ||
        fileName.contains('.png')) {
      return Icons.image_rounded;
    }
    return Icons.insert_drive_file_rounded;
  }

  Future<void> _downloadDocument(BuildContext context) async {
    if (document.documentFile == null || document.documentFile!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document URL not available')),
      );
      return;
    }

    // Copy URL to clipboard as a fallback
    await Clipboard.setData(ClipboardData(text: document.documentFile!));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document URL copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
