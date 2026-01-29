import 'package:flutter/material.dart';
import 'package:school_management_system/features/class/blocs/create_class/create_class_state.dart';
import 'package:school_management_system/shared/styles/app_styles.dart';
import 'package:school_management_system/shared/widgets/text/gradiant_text.dart';

/// Step 2 of Create Class flow - Subject and teacher assignments.
class SubjectsStep extends StatelessWidget {
  const SubjectsStep({
    super.key,
    required this.subjects,
    required this.teachers,
    required this.onAddSubject,
    required this.onRemoveSubject,
    required this.onSubjectChanged,
    required this.onTeacherChanged,
    required this.formKey,
  });

  final List<SubjectTeacherModel> subjects;
  final List<String> teachers;
  final VoidCallback onAddSubject;
  final void Function(int index) onRemoveSubject;
  final void Function(int index, String value) onSubjectChanged;
  final void Function(int index, String? value) onTeacherChanged;
  final GlobalKey<FormState> formKey;

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
              'Class Details',
              style: AppTextStyles.heading4.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),

            // Subject-Teacher pairs
            ...List.generate(subjects.length, (index) {
              return _buildSubjectTeacherRow(context, index);
            }),

            const SizedBox(height: 10),

            // Add Subject button
            Center(
              child: GestureDetector(
                onTap: onAddSubject,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GradientText(
                        'Add Subject',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectTeacherRow(BuildContext context, int index) {
    final subject = subjects[index];
    final canRemove = subjects.length > 1;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subject field
          Expanded(
            child: _SubjectField(
              index: index,
              initialValue: subject.subjectName,
              onChanged: (value) => onSubjectChanged(index, value),
            ),
          ),
          const SizedBox(width: 8),
          // Teacher dropdown
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _TeacherDropdown(
                    index: index,
                    value: subject.teacherName,
                    teachers: teachers,
                    onChanged: (value) => onTeacherChanged(index, value),
                  ),
                ),
                if (canRemove) ...[
                  GestureDetector(
                    onTap: () => onRemoveSubject(index),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 13,
                        horizontal: 8,
                      ),

                      child: Icon(
                        Icons.remove_circle_outline,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Remove button
        ],
      ),
    );
  }
}

class _SubjectField extends StatefulWidget {
  const _SubjectField({
    required this.index,
    required this.initialValue,
    required this.onChanged,
  });

  final int index;
  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  State<_SubjectField> createState() => _SubjectFieldState();
}

class _SubjectFieldState extends State<_SubjectField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant _SubjectField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update if the initial value changed and differs from current text
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Subject ${widget.index + 1}', style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: _controller,
          onChanged: widget.onChanged,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Enter class',
            hintStyle: AppTextStyles.hint,
            filled: true,
            fillColor: AppColors.cardBackground,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
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
}

class _TeacherDropdown extends StatelessWidget {
  const _TeacherDropdown({
    required this.index,
    required this.value,
    required this.teachers,
    required this.onChanged,
  });

  final int index;
  final String? value;
  final List<String> teachers;
  final ValueChanged<String?> onChanged;

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TeacherBottomSheet(
        selectedValue: value,
        teachers: teachers,
        onItemSelected: (item) {
          onChanged(item);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Teacher', style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showBottomSheet(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value ?? 'Select Teacher',
                    style: value != null
                        ? AppTextStyles.bodyMedium
                        : AppTextStyles.hint,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TeacherBottomSheet extends StatefulWidget {
  const _TeacherBottomSheet({
    required this.selectedValue,
    required this.teachers,
    required this.onItemSelected,
  });

  final String? selectedValue;
  final List<String> teachers;
  final ValueChanged<String> onItemSelected;

  @override
  State<_TeacherBottomSheet> createState() => _TeacherBottomSheetState();
}

class _TeacherBottomSheetState extends State<_TeacherBottomSheet> {
  late List<String> _filteredTeachers;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredTeachers = widget.teachers;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterTeachers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredTeachers = widget.teachers;
      } else {
        _filteredTeachers = widget.teachers
            .where((t) => t.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
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
                Expanded(
                  child: Text('Select Teacher', style: AppTextStyles.heading4),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.border.withAlpha(100),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: _filterTeachers,
              decoration: InputDecoration(
                hintText: 'Search teacher...',
                hintStyle: AppTextStyles.hint,
                prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          // Teachers list
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.only(bottom: bottomPadding + 16),
              itemCount: _filteredTeachers.length,
              itemBuilder: (context, index) {
                final teacher = _filteredTeachers[index];
                final isSelected = teacher == widget.selectedValue;

                return InkWell(
                  onTap: () => widget.onItemSelected(teacher),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withAlpha(15)
                          : Colors.transparent,
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.border.withAlpha(100),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Teacher avatar
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withAlpha(20),
                          ),
                          child: Icon(
                            Icons.person,
                            size: 20,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            teacher,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                              fontWeight: isSelected
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
