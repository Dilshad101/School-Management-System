import 'package:flutter/material.dart';

import '../../../../shared/styles/app_styles.dart';
import '../../models/guardian_model.dart';

/// A card widget to display linked student information with relation input.
class LinkedStudentCard extends StatefulWidget {
  const LinkedStudentCard({
    super.key,
    required this.student,
    required this.onRemove,
    this.onView,
    this.onRelationChanged,
    this.showRelationField = true,
  });

  final LinkedStudentModel student;
  final VoidCallback onRemove;
  final VoidCallback? onView;
  final ValueChanged<String>? onRelationChanged;
  final bool showRelationField;

  @override
  State<LinkedStudentCard> createState() => _LinkedStudentCardState();
}

class _LinkedStudentCardState extends State<LinkedStudentCard> {
  late TextEditingController _relationController;

  @override
  void initState() {
    super.initState();
    _relationController = TextEditingController(text: widget.student.relation);
  }

  @override
  void didUpdateWidget(LinkedStudentCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.student.relation != widget.student.relation) {
      _relationController.text = widget.student.relation;
    }
  }

  @override
  void dispose() {
    _relationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Profile image
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.border.withAlpha(50),
                backgroundImage: widget.student.profilePic != null
                    ? NetworkImage(widget.student.profilePic!)
                    : null,
                child: widget.student.profilePic == null
                    ? Icon(
                        Icons.person,
                        size: 24,
                        color: AppColors.textPrimary.withAlpha(160),
                      )
                    : null,
              ),
              const SizedBox(width: 12),

              // Student info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.student.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          widget.student.classInfo,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (widget.student.displayId.isNotEmpty) ...[
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            width: 1,
                            height: 12,
                            color: AppColors.border,
                          ),
                          Expanded(
                            child: Text(
                              widget.student.displayId,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // View button
              // if (widget.onView != null)
              //   TextButton(
              //     onPressed: widget.onView,
              //     style: TextButton.styleFrom(
              //       padding: const EdgeInsets.symmetric(
              //         horizontal: 16,
              //         vertical: 8,
              //       ),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(8),
              //         side: const BorderSide(color: AppColors.primary),
              //       ),
              //     ),
              //     child: Text(
              //       'View',
              //       style: AppTextStyles.bodySmall.copyWith(
              //         color: AppColors.primary,
              //         fontWeight: FontWeight.w500,
              //       ),
              //     ),
              //   ),

              // Remove button
              IconButton(
                onPressed: widget.onRemove,
                icon: const Icon(
                  Icons.close,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                tooltip: 'Remove student',
              ),
            ],
          ),

          // Relation input field
          if (widget.showRelationField) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: _relationController,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Enter relation (e.g., Father, Mother, Uncle)',
                hintStyle: AppTextStyles.hint,
                labelText: 'Relation *',
                labelStyle: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                filled: true,
                fillColor: AppColors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: widget.student.relation.isEmpty
                        ? AppColors.borderError
                        : AppColors.border,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: widget.student.relation.isEmpty
                        ? AppColors.borderError.withAlpha(150)
                        : AppColors.border,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.borderError,
                    width: 1,
                  ),
                ),
              ),
              onChanged: widget.onRelationChanged,
            ),
          ],
        ],
      ),
    );
  }
}
