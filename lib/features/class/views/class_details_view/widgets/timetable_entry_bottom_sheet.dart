import 'package:flutter/material.dart';

import '../../../../../core/utils/di.dart';
import '../../../../../shared/styles/app_styles.dart';
import '../../../../../shared/widgets/buttons/gradient_button.dart';
import '../../../../../shared/widgets/input_fields/suggestion_form_field.dart';
import '../../../../employees/models/employee_model.dart';
import '../../../../employees/repositories/employees_repository.dart';
import '../../../../settings/models/subject_model.dart';
import '../../../../settings/repositories/subject_repository.dart';

/// Result returned from the TimetableEntryBottomSheet.
class TimetableEntryResult {
  final String subjectId;
  final String subjectName;
  final String teacherId;
  final String teacherName;

  TimetableEntryResult({
    required this.subjectId,
    required this.subjectName,
    required this.teacherId,
    required this.teacherName,
  });
}

/// Bottom sheet for adding or editing a timetable entry.
class TimetableEntryBottomSheet extends StatefulWidget {
  final String periodName;
  final String dayName;
  final String? initialSubjectId;
  final String? initialSubjectName;
  final String? initialTeacherId;
  final String? initialTeacherName;
  final bool isEditing;

  const TimetableEntryBottomSheet({
    super.key,
    required this.periodName,
    required this.dayName,
    this.initialSubjectId,
    this.initialSubjectName,
    this.initialTeacherId,
    this.initialTeacherName,
    this.isEditing = false,
  });

  /// Shows the bottom sheet and returns the result.
  static Future<TimetableEntryResult?> show(
    BuildContext context, {
    required String periodName,
    required String dayName,
    String? initialSubjectId,
    String? initialSubjectName,
    String? initialTeacherId,
    String? initialTeacherName,
    bool isEditing = false,
  }) {
    return showModalBottomSheet<TimetableEntryResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => TimetableEntryBottomSheet(
        periodName: periodName,
        dayName: dayName,
        initialSubjectId: initialSubjectId,
        initialSubjectName: initialSubjectName,
        initialTeacherId: initialTeacherId,
        initialTeacherName: initialTeacherName,
        isEditing: isEditing,
      ),
    );
  }

  @override
  State<TimetableEntryBottomSheet> createState() =>
      _TimetableEntryBottomSheetState();
}

class _TimetableEntryBottomSheetState extends State<TimetableEntryBottomSheet> {
  final _subjectController = TextEditingController();
  final _teacherController = TextEditingController();

  String? _selectedSubjectId;
  String? _selectedSubjectName;
  String? _selectedTeacherId;
  String? _selectedTeacherName;

  late final SubjectRepository _subjectRepository;
  late final EmployeesRepository _employeesRepository;

  @override
  void initState() {
    super.initState();
    _subjectRepository = locator<SubjectRepository>();
    _employeesRepository = locator<EmployeesRepository>();

    if (widget.initialSubjectId != null) {
      _selectedSubjectId = widget.initialSubjectId;
      _selectedSubjectName = widget.initialSubjectName;
      _subjectController.text = widget.initialSubjectName ?? '';
    }
    if (widget.initialTeacherId != null) {
      _selectedTeacherId = widget.initialTeacherId;
      _selectedTeacherName = widget.initialTeacherName;
      _teacherController.text = widget.initialTeacherName ?? '';
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _teacherController.dispose();
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
      child: SingleChildScrollView(
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
                  widget.isEditing ? 'Edit Schedule' : 'Add Schedule',
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
            const SizedBox(height: 8),

            // Period and Day info
            Center(
              child: Text(
                '${widget.periodName} • ${widget.dayName}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Subject Field
            SuggestionFormField<SubjectModel>(
              controller: _subjectController,
              label: 'Subject',
              hint: 'Search and select subject',
              isRequired: true,
              suggestionsCallback: _searchSubjects,
              itemBuilder: (context, subject) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    radius: 18,
                    child: Icon(
                      subject.isLab
                          ? Icons.science_outlined
                          : Icons.book_outlined,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  title: Text(subject.name),
                  subtitle: subject.code != null ? Text(subject.code!) : null,
                  trailing: subject.isLab
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Lab',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : null,
                  dense: true,
                );
              },
              onSelected: (subject) {
                _selectedSubjectId = subject.id;
                _selectedSubjectName = subject.name;
                _subjectController.text = subject.name;
              },
            ),
            const SizedBox(height: 16),

            // Teacher Field
            SuggestionFormField<EmployeeModel>(
              controller: _teacherController,
              label: 'Teacher',
              hint: 'Search and select teacher',
              isRequired: true,
              suggestionsCallback: _searchTeachers,
              itemBuilder: (context, teacher) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    backgroundImage: teacher.profilePicUrl != null
                        ? NetworkImage(teacher.profilePicUrl!)
                        : null,
                    child: teacher.profilePicUrl == null
                        ? Text(
                            teacher.fullName.isNotEmpty
                                ? teacher.fullName[0].toUpperCase()
                                : 'T',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : null,
                  ),
                  title: Text(teacher.fullName),
                  subtitle: Text(teacher.email),
                  dense: true,
                );
              },
              onSelected: (teacher) {
                _selectedTeacherId = teacher.id;
                _selectedTeacherName = teacher.fullName;
                _teacherController.text = teacher.fullName;
              },
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
      ),
    );
  }

  Future<List<SubjectModel>> _searchSubjects(String query) async {
    try {
      final response = await _subjectRepository.getSubjects(
        page: 1,
        pageSize: 10,
        search: query,
      );
      return response.results;
    } catch (e) {
      return [];
    }
  }

  Future<List<EmployeeModel>> _searchTeachers(String query) async {
    try {
      final response = await _employeesRepository.getEmployees(
        page: 1,
        pageSize: 10,
        search: query,
      );
      return response.results;
    } catch (e) {
      return [];
    }
  }

  void _onSubmit() {
    if (_selectedSubjectId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a subject')));
      return;
    }

    if (_selectedTeacherId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a teacher')));
      return;
    }

    Navigator.pop(
      context,
      TimetableEntryResult(
        subjectId: _selectedSubjectId!,
        subjectName: _selectedSubjectName!,
        teacherId: _selectedTeacherId!,
        teacherName: _selectedTeacherName!,
      ),
    );
  }
}
