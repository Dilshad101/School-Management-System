import 'package:flutter/material.dart';
import 'package:school_management_system/shared/styles/app_styles.dart';
import 'package:school_management_system/shared/widgets/input_fields/simple_form_field.dart';
import 'package:school_management_system/shared/widgets/input_fields/suggestion_form_field.dart';

import '../../../models/academic_year_model.dart';
import '../../../models/school_user_model.dart';

/// Single step class form - Basic class details with suggestion fields.
class ClassDetailsStep extends StatefulWidget {
  const ClassDetailsStep({
    super.key,
    required this.className,
    required this.roomNo,
    required this.selectedAcademicYear,
    required this.selectedClassTeacher,
    required this.onClassNameChanged,
    required this.onRoomNoChanged,
    required this.onAcademicYearChanged,
    required this.onClassTeacherChanged,
    required this.searchAcademicYears,
    required this.searchSchoolUsers,
    required this.formKey,
  });

  final String className;
  final String roomNo;
  final AcademicYearModel? selectedAcademicYear;
  final SchoolUserModel? selectedClassTeacher;
  final ValueChanged<String> onClassNameChanged;
  final ValueChanged<String> onRoomNoChanged;
  final ValueChanged<AcademicYearModel?> onAcademicYearChanged;
  final ValueChanged<SchoolUserModel?> onClassTeacherChanged;
  final Future<List<AcademicYearModel>> Function(String) searchAcademicYears;
  final Future<List<SchoolUserModel>> Function(String) searchSchoolUsers;
  final GlobalKey<FormState> formKey;

  @override
  State<ClassDetailsStep> createState() => _ClassDetailsStepState();
}

class _ClassDetailsStepState extends State<ClassDetailsStep> {
  late TextEditingController _classNameController;
  late TextEditingController _roomNoController;
  late TextEditingController _academicYearController;
  late TextEditingController _classTeacherController;

  @override
  void initState() {
    super.initState();
    _classNameController = TextEditingController(text: widget.className);
    _roomNoController = TextEditingController(text: widget.roomNo);
    _academicYearController = TextEditingController(
      text: widget.selectedAcademicYear?.name ?? '',
    );
    _classTeacherController = TextEditingController(
      text: widget.selectedClassTeacher?.fullName ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant ClassDetailsStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync controllers if values changed externally (e.g., reset)
    if (widget.className != oldWidget.className &&
        widget.className != _classNameController.text) {
      _classNameController.text = widget.className;
    }
    if (widget.roomNo != oldWidget.roomNo &&
        widget.roomNo != _roomNoController.text) {
      _roomNoController.text = widget.roomNo;
    }
    if (widget.selectedAcademicYear != oldWidget.selectedAcademicYear) {
      _academicYearController.text = widget.selectedAcademicYear?.name ?? '';
    }
    if (widget.selectedClassTeacher != oldWidget.selectedClassTeacher) {
      _classTeacherController.text =
          widget.selectedClassTeacher?.fullName ?? '';
    }
  }

  @override
  void dispose() {
    _classNameController.dispose();
    _roomNoController.dispose();
    _academicYearController.dispose();
    _classTeacherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
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

            // Class name field
            SimpleFormField(
              controller: _classNameController,
              label: 'Class Name',
              hint: 'Enter class name (e.g., 5A)',
              onChanged: widget.onClassNameChanged,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Class name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Room number field
            SimpleFormField(
              controller: _roomNoController,
              label: 'Room Number',
              hint: 'Enter room number (optional)',
              onChanged: widget.onRoomNoChanged,
            ),
            const SizedBox(height: 16),

            // Academic year suggestion field
            SuggestionFormField<AcademicYearModel>(
              controller: _academicYearController,
              label: 'Academic Year',
              hint: 'Search academic year',
              isRequired: true,
              suggestionsCallback: widget.searchAcademicYears,
              itemBuilder: (context, academicYear) {
                return ListTile(
                  dense: true,
                  title: Text(
                    academicYear.name,
                    style: AppTextStyles.bodyMedium,
                  ),
                  subtitle:
                      academicYear.startDate != null &&
                          academicYear.endDate != null
                      ? Text(
                          '${academicYear.startDate} - ${academicYear.endDate}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        )
                      : null,
                  trailing: academicYear.isCurrent
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.green.withAlpha(30),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Current',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : null,
                );
              },
              onSelected: (academicYear) {
                _academicYearController.text = academicYear.name;
                widget.onAcademicYearChanged(academicYear);
              },
              validator: (value) {
                if (widget.selectedAcademicYear == null) {
                  return 'Please select an academic year';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Class teacher suggestion field
            SuggestionFormField<SchoolUserModel>(
              controller: _classTeacherController,
              label: 'Class Teacher',
              hint: 'Search teacher by name or email',
              isRequired: true,
              suggestionsCallback: widget.searchSchoolUsers,
              itemBuilder: (context, user) {
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary.withAlpha(30),
                    backgroundImage: user.profile?.profilePic != null
                        ? NetworkImage(user.profile!.profilePic!)
                        : null,
                    child: user.profile?.profilePic == null
                        ? Text(
                            user.firstName.isNotEmpty
                                ? user.firstName[0].toUpperCase()
                                : '?',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : null,
                  ),
                  title: Text(user.fullName, style: AppTextStyles.bodyMedium),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        user.email,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      // if (user.rolesDetails.isNotEmpty)
                      //   Wrap(
                      //     spacing: 4,
                      //     children: user.rolesDetails.map((role) {
                      //       return Container(
                      //         margin: const EdgeInsets.only(top: 4),
                      //         padding: const EdgeInsets.symmetric(
                      //           horizontal: 6,
                      //           vertical: 2,
                      //         ),
                      //         decoration: BoxDecoration(
                      //           color: AppColors.primary.withAlpha(20),
                      //           borderRadius: BorderRadius.circular(4),
                      //         ),
                      //         child: Text(
                      //           role.name,
                      //           style: AppTextStyles.bodySmall.copyWith(
                      //             color: AppColors.primary,
                      //             fontSize: 10,
                      //           ),
                      //         ),
                      //       );
                      //     }).toList(),
                      //   ),
                    ],
                  ),
                );
              },
              onSelected: (user) {
                _classTeacherController.text = user.fullName;
                widget.onClassTeacherChanged(user);
              },
              validator: (value) {
                if (widget.selectedClassTeacher == null) {
                  return 'Please select a class teacher';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
