import 'package:flutter/material.dart';
import 'package:school_management_system/shared/styles/app_styles.dart';
import 'package:school_management_system/shared/widgets/dropdowns/bottom_sheet_dropdown.dart';
import 'package:school_management_system/shared/widgets/input_fields/simple_form_field.dart';

/// Step 1 of Create Class flow - Basic class details.
class ClassDetailsStep extends StatefulWidget {
  const ClassDetailsStep({
    super.key,
    required this.className,
    required this.roomNo,
    required this.academicYear,
    required this.classTeacher,
    required this.selectedDivision,
    required this.onClassNameChanged,
    required this.onRoomNoChanged,
    required this.onAcademicYearChanged,
    required this.onClassTeacherChanged,
    required this.onDivisionChanged,
    required this.divisions,
    required this.formKey,
  });

  final String className;
  final String roomNo;
  final String academicYear;
  final String classTeacher;
  final String? selectedDivision;
  final ValueChanged<String> onClassNameChanged;
  final ValueChanged<String> onRoomNoChanged;
  final ValueChanged<String> onAcademicYearChanged;
  final ValueChanged<String> onClassTeacherChanged;
  final ValueChanged<String?> onDivisionChanged;
  final List<String> divisions;
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
    _academicYearController = TextEditingController(text: widget.academicYear);
    _classTeacherController = TextEditingController(text: widget.classTeacher);
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
    if (widget.academicYear != oldWidget.academicYear &&
        widget.academicYear != _academicYearController.text) {
      _academicYearController.text = widget.academicYear;
    }
    if (widget.classTeacher != oldWidget.classTeacher &&
        widget.classTeacher != _classTeacherController.text) {
      _classTeacherController.text = widget.classTeacher;
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
              label: 'Class',
              hint: 'Enter class name',
              onChanged: widget.onClassNameChanged,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Class name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Division dropdown
            BottomSheetDropdown<String>(
              label: 'Division',
              hint: 'Select Division',
              items: widget.divisions,
              value: widget.selectedDivision,
              onChanged: widget.onDivisionChanged,
              validator: (value) {
                if (value == null) {
                  return 'Please select a division';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Room number field
            SimpleFormField(
              controller: _roomNoController,
              label: 'Room NO',
              hint: 'Enter room no',
              onChanged: widget.onRoomNoChanged,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Room number is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Academic year field
            SimpleFormField(
              controller: _academicYearController,
              label: 'Academic Year',
              hint: '0000 - 0000',
              onChanged: widget.onAcademicYearChanged,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Academic year is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Class teacher field
            SimpleFormField(
              controller: _classTeacherController,
              label: 'Class Teacher',
              hint: 'Enter name or ID',
              onChanged: widget.onClassTeacherChanged,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Class teacher is required';
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
