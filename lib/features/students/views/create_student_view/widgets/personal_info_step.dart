import 'package:flutter/material.dart';
import 'package:school_management_system/core/utils/validations.dart';
import 'package:school_management_system/shared/styles/app_styles.dart';
import 'package:school_management_system/shared/widgets/dropdowns/bottom_sheet_dropdown.dart';
import 'package:school_management_system/shared/widgets/input_fields/simple_form_field.dart';

import '../../../models/academic_year_model.dart';
import '../../../models/class_room_model.dart';
import 'icon_form_field.dart';
import 'date_picker_field.dart';

/// Step 1 of Create Student flow - Personal Information.
class PersonalInfoStep extends StatefulWidget {
  const PersonalInfoStep({
    super.key,
    required this.formKey,
    required this.fullName,
    required this.selectedClassRoom,
    required this.selectedAcademicYear,
    required this.dateOfBirth,
    required this.selectedGender,
    required this.selectedBloodGroup,
    required this.address,
    required this.email,
    required this.phone,
    required this.studentId,
    required this.roleNumber,
    required this.classRooms,
    required this.genders,
    required this.academicYears,
    required this.bloodGroups,
    required this.onFullNameChanged,
    required this.onClassRoomChanged,
    required this.onAcademicYearChanged,
    required this.onRoleNumberChanged,
    required this.onDateOfBirthChanged,
    required this.onGenderChanged,
    required this.onBloodGroupChanged,
    required this.onAddressChanged,
    required this.onEmailChanged,
    required this.onPhoneChanged,
  });

  final GlobalKey<FormState> formKey;
  final String fullName;
  final ClassRoomModel? selectedClassRoom;
  final AcademicYearModel? selectedAcademicYear;
  final DateTime? dateOfBirth;
  final String? selectedGender;
  final String? selectedBloodGroup;
  final String address;
  final String email;
  final String phone;
  final String studentId;
  final String roleNumber;
  final List<ClassRoomModel> classRooms;
  final List<String> genders;
  final List<String> bloodGroups;
  final List<AcademicYearModel> academicYears;
  final ValueChanged<String> onFullNameChanged;
  final ValueChanged<ClassRoomModel?> onClassRoomChanged;
  final ValueChanged<AcademicYearModel?> onAcademicYearChanged;
  final ValueChanged<String> onRoleNumberChanged;
  final ValueChanged<DateTime?> onDateOfBirthChanged;
  final ValueChanged<String?> onGenderChanged;
  final ValueChanged<String?> onBloodGroupChanged;
  final ValueChanged<String> onAddressChanged;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPhoneChanged;

  @override
  State<PersonalInfoStep> createState() => _PersonalInfoStepState();
}

class _PersonalInfoStepState extends State<PersonalInfoStep> {
  late TextEditingController _fullNameController;
  late TextEditingController _roleNumberController;
  late TextEditingController _addressController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _studentIdController;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.fullName);
    _roleNumberController = TextEditingController(text: widget.roleNumber);
    _addressController = TextEditingController(text: widget.address);
    _emailController = TextEditingController(text: widget.email);
    _phoneController = TextEditingController(text: widget.phone);
    _studentIdController = TextEditingController(text: widget.studentId);
  }

  @override
  void didUpdateWidget(covariant PersonalInfoStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncController(_fullNameController, widget.fullName, oldWidget.fullName);
    _syncController(
      _roleNumberController,
      widget.roleNumber,
      oldWidget.roleNumber,
    );
    _syncController(_addressController, widget.address, oldWidget.address);
    _syncController(_emailController, widget.email, oldWidget.email);
    _syncController(_phoneController, widget.phone, oldWidget.phone);
    _syncController(
      _studentIdController,
      widget.studentId,
      oldWidget.studentId,
    );
  }

  void _syncController(
    TextEditingController controller,
    String newValue,
    String oldValue,
  ) {
    if (newValue != oldValue && newValue != controller.text) {
      controller.text = newValue;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _studentIdController.dispose();
    _roleNumberController.dispose();
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
              'Personal Information',
              style: AppTextStyles.heading4.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),

            // Full Name
            IconFormField(
              controller: _fullNameController,
              label: 'Full Name',
              hint: 'Enter full name',
              icon: Icons.person_outline,
              onChanged: widget.onFullNameChanged,
              isRequired: true,
              validator: (value) =>
                  Validations.validateRequiredField(value, 'Full name'),
            ),
            const SizedBox(height: 16),

            // Class and Division row
            BottomSheetDropdown<ClassRoomModel>(
              label: 'Class',
              hint: 'Select class',
              items: widget.classRooms,
              value: widget.selectedClassRoom,
              onChanged: widget.onClassRoomChanged,
              itemLabelBuilder: (item) => item.name,
              isRequired: true,
              validator: (value) {
                if (value == null) {
                  return 'Please select a class';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Academic Year
            SimpleFormField(
              controller: _roleNumberController,
              label: 'Role Number',
              isRequired: true,
              hint: 'Enter role number',
              onChanged: widget.onRoleNumberChanged,
              validator: (value) =>
                  Validations.validateRequiredField(value, 'Role number'),
            ),
            const SizedBox(height: 16),

            // Academic Year
            BottomSheetDropdown<AcademicYearModel>(
              label: 'Academic Year',
              hint: 'Select academic year',
              items: widget.academicYears,
              value: widget.selectedAcademicYear,
              onChanged: widget.onAcademicYearChanged,
              itemLabelBuilder: (item) => item.name,
              isRequired: true,
              validator: (value) {
                if (value == null) {
                  return 'Please select an academic year';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Date of Birth
            DatePickerField(
              label: 'Date Of Birth',
              hint: 'Select date of birth',
              value: widget.dateOfBirth,
              isRequired: true,
              onChanged: widget.onDateOfBirthChanged,
              validator: (value) {
                if (value == null) {
                  return 'Date of birth is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Gender
            BottomSheetDropdown<String>(
              label: 'Gender',
              hint: 'Select Gender',
              items: widget.genders,
              value: widget.selectedGender,
              onChanged: widget.onGenderChanged,
            ),
            const SizedBox(height: 16),

            // Blood Group
            BottomSheetDropdown<String>(
              label: 'Blood Group',
              hint: 'Select blood group',
              items: widget.bloodGroups,
              value: widget.selectedBloodGroup,
              onChanged: widget.onBloodGroupChanged,
            ),
            const SizedBox(height: 16),

            // Address
            IconFormField(
              controller: _addressController,
              label: 'Address',
              hint: 'Enter Address',
              icon: Icons.location_on_outlined,
              isRequired: true,
              onChanged: widget.onAddressChanged,
              validator: (value) =>
                  Validations.validateRequiredField(value, 'Address'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Email
            IconFormField(
              controller: _emailController,
              label: 'Email',
              hint: 'Enter your Email',
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              isRequired: true,
              onChanged: widget.onEmailChanged,
              validator: (value) => Validations.validateEmail(value),
            ),
            const SizedBox(height: 16),

            // Phone
            IconFormField(
              controller: _phoneController,
              label: 'Phone',
              hint: 'Enter phone number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              onChanged: widget.onPhoneChanged,
            ),
            const SizedBox(height: 16),

            // Student ID (Auto Generated)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Student ID', style: AppTextStyles.labelMedium),
                    const SizedBox(width: 4),
                    Text(
                      '(Auto Generated)',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                IconFormField(
                  controller: _studentIdController,
                  label: '',
                  hint: 'Enter student ID',
                  icon: Icons.badge_outlined,
                  enabled: false,
                  showLabel: false,
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
