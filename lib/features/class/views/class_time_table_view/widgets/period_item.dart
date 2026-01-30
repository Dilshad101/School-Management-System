import 'package:flutter/material.dart';
import 'package:school_management_system/features/class/blocs/timetable/timetable_state.dart';
import 'package:school_management_system/shared/styles/app_styles.dart';

/// A single period item with subject input and teacher dropdown.
class PeriodItem extends StatefulWidget {
  const PeriodItem({
    super.key,
    required this.periodNumber,
    required this.period,
    required this.teachers,
    required this.onSubjectChanged,
    required this.onTeacherChanged,
    this.onRemove,
  });

  final int periodNumber;
  final PeriodModel period;
  final List<TeacherModel> teachers;
  final ValueChanged<String> onSubjectChanged;
  final ValueChanged<TeacherModel?> onTeacherChanged;
  final VoidCallback? onRemove;

  @override
  State<PeriodItem> createState() => _PeriodItemState();
}

class _PeriodItemState extends State<PeriodItem> {
  late TextEditingController _subjectController;

  @override
  void initState() {
    super.initState();
    _subjectController = TextEditingController(text: widget.period.subject);
  }

  @override
  void didUpdateWidget(covariant PeriodItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.period.subject != widget.period.subject) {
      _subjectController.text = widget.period.subject;
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subject field
        Expanded(child: _buildSubjectField()),
        const SizedBox(width: 12),
        // Teacher dropdown
        Expanded(child: _buildTeacherDropdown()),
      ],
    );
  }

  Widget _buildSubjectField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Period ${widget.periodNumber}', style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: _subjectController,
          style: AppTextStyles.bodyMedium,
          onChanged: widget.onSubjectChanged,
          decoration: InputDecoration(
            hintText: 'Enter Subject',
            hintStyle: AppTextStyles.hint,
            filled: true,
            fillColor: AppColors.cardBackground,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border, width: 1),
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
      ],
    );
  }

  Widget _buildTeacherDropdown() {
    // Find selected teacher
    TeacherModel? selectedTeacher;
    if (widget.period.teacherId != null) {
      try {
        selectedTeacher = widget.teachers.firstWhere(
          (t) => t.id == widget.period.teacherId,
        );
      } catch (_) {
        selectedTeacher = null;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Teacher', style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showTeacherBottomSheet(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedTeacher?.name ?? 'Select Teacher',
                    style: selectedTeacher != null
                        ? AppTextStyles.bodyMedium
                        : AppTextStyles.hint,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showTeacherBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TeacherSelectionBottomSheet(
        teachers: widget.teachers,
        selectedTeacherId: widget.period.teacherId,
        onTeacherSelected: (teacher) {
          widget.onTeacherChanged(teacher);
          Navigator.pop(context);
        },
      ),
    );
  }
}

/// Bottom sheet for selecting a teacher.
class _TeacherSelectionBottomSheet extends StatelessWidget {
  const _TeacherSelectionBottomSheet({
    required this.teachers,
    required this.selectedTeacherId,
    required this.onTeacherSelected,
  });

  final List<TeacherModel> teachers;
  final String? selectedTeacherId;
  final ValueChanged<TeacherModel?> onTeacherSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Expanded(
                  child: Text('Select Teacher', style: AppTextStyles.heading4),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Teacher list
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: teachers.length,
              itemBuilder: (context, index) {
                final teacher = teachers[index];
                final isSelected = teacher.id == selectedTeacherId;

                return ListTile(
                  title: Text(
                    teacher.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () => onTeacherSelected(teacher),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
