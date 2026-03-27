import 'package:flutter/material.dart';

import '../../../../../shared/styles/app_styles.dart';
import '../../../models/document_model.dart';
import '../../../models/student_model.dart';
import 'info_field.dart';

/// Tab content for displaying student information.
class StudentInfoTab extends StatelessWidget {
  const StudentInfoTab({super.key, required this.student});

  final StudentModel student;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Student Information', style: AppTextStyles.heading4),
          const SizedBox(height: 16),
          InfoField(
            label: 'Date Of Birth',
            value: _formatDate(student.profile?.dateOfBirth),
          ),
          const SizedBox(height: 16),
          InfoField(label: 'Gender', value: student.profile?.gender ?? ''),
          const SizedBox(height: 16),
          InfoField(
            label: 'Blood Group',
            value: student.profile?.bloodGroup ?? '',
          ),
          const SizedBox(height: 16),
          InfoField(label: 'Address', value: student.profile?.address ?? ''),
          const SizedBox(height: 16),
          InfoField(label: 'Email', value: student.email),
          const SizedBox(height: 16),
          InfoField(label: 'Phone', value: student.phone ?? ''),
          const SizedBox(height: 24),
          // Documents section
          _DocumentsSection(documents: student.documents),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (_) {
      return dateStr;
    }
  }
}

class _DocumentsSection extends StatelessWidget {
  const _DocumentsSection({required this.documents});

  final List<DocumentModel> documents;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Documents', style: AppTextStyles.heading4),
            // Upload button (disabled for now - would be enabled in edit mode)
            TextButton.icon(
              onPressed: null, // Disabled in view mode
              icon: const Icon(Icons.upload_outlined, size: 18),
              label: const Text('Upload'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (documents.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
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
          ...documents.map((doc) => _DocumentItem(document: doc)),
      ],
    );
  }
}

class _DocumentItem extends StatelessWidget {
  const _DocumentItem({required this.document});

  final DocumentModel document;

  @override
  Widget build(BuildContext context) {
    final name = document.documentName ?? 'Document';

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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.description_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: AppTextStyles.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Implement download
            },
            icon: Icon(Icons.download_outlined, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
