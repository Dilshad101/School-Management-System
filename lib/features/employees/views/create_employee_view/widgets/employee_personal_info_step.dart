import 'package:flutter/material.dart';
import 'package:school_management_system/shared/styles/app_styles.dart';
import 'package:school_management_system/shared/widgets/dropdowns/bottom_sheet_dropdown.dart';

import '../../../../../features/students/views/create_student_view/widgets/date_picker_field.dart';
import '../../../../../features/students/views/create_student_view/widgets/icon_form_field.dart';

/// Step 1 of Create Employee flow - Personal Information.
class EmployeePersonalInfoStep extends StatefulWidget {
  const EmployeePersonalInfoStep({
    super.key,
    required this.formKey,
    required this.fullName,
    required this.mobileNo,
    required this.joiningDate,
    required this.selectedSubjects,
    required this.selectedGender,
    required this.selectedBloodGroup,
    required this.address,
    required this.email,
    required this.employeeId,
    required this.subjects,
    required this.genders,
    required this.bloodGroups,
    required this.categoryLabel,
    required this.onFullNameChanged,
    required this.onMobileNoChanged,
    required this.onJoiningDateChanged,
    required this.onSubjectAdded,
    required this.onSubjectRemoved,
    required this.onGenderChanged,
    required this.onBloodGroupChanged,
    required this.onAddressChanged,
    required this.onEmailChanged,
  });

  final GlobalKey<FormState> formKey;
  final String fullName;
  final String mobileNo;
  final DateTime? joiningDate;
  final List<String> selectedSubjects;
  final String? selectedGender;
  final String? selectedBloodGroup;
  final String address;
  final String email;
  final String employeeId;
  final List<String> subjects;
  final List<String> genders;
  final List<String> bloodGroups;
  final String categoryLabel;
  final ValueChanged<String> onFullNameChanged;
  final ValueChanged<String> onMobileNoChanged;
  final ValueChanged<DateTime?> onJoiningDateChanged;
  final ValueChanged<String> onSubjectAdded;
  final ValueChanged<String> onSubjectRemoved;
  final ValueChanged<String?> onGenderChanged;
  final ValueChanged<String?> onBloodGroupChanged;
  final ValueChanged<String> onAddressChanged;
  final ValueChanged<String> onEmailChanged;

  @override
  State<EmployeePersonalInfoStep> createState() =>
      _EmployeePersonalInfoStepState();
}

class _EmployeePersonalInfoStepState extends State<EmployeePersonalInfoStep> {
  late TextEditingController _fullNameController;
  late TextEditingController _mobileNoController;
  late TextEditingController _addressController;
  late TextEditingController _emailController;
  late TextEditingController _employeeIdController;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.fullName);
    _mobileNoController = TextEditingController(text: widget.mobileNo);
    _addressController = TextEditingController(text: widget.address);
    _emailController = TextEditingController(text: widget.email);
    _employeeIdController = TextEditingController(text: widget.employeeId);
  }

  @override
  void didUpdateWidget(covariant EmployeePersonalInfoStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncController(_fullNameController, widget.fullName, oldWidget.fullName);
    _syncController(_mobileNoController, widget.mobileNo, oldWidget.mobileNo);
    _syncController(_addressController, widget.address, oldWidget.address);
    _syncController(_emailController, widget.email, oldWidget.email);
    _syncController(
      _employeeIdController,
      widget.employeeId,
      oldWidget.employeeId,
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
    _mobileNoController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _employeeIdController.dispose();
    super.dispose();
  }

  void _showSubjectSelector(BuildContext context) {
    final availableSubjects = widget.subjects
        .where((s) => !widget.selectedSubjects.contains(s))
        .toList();

    if (availableSubjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All subjects have been selected')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SubjectSelectorBottomSheet(
        subjects: availableSubjects,
        onSubjectSelected: (subject) {
          widget.onSubjectAdded(subject);
          Navigator.pop(context);
        },
      ),
    );
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
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Full name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Mobile Number
            IconFormField(
              controller: _mobileNoController,
              label: 'Mobile NO',
              hint: '91 00000 00000',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              onChanged: widget.onMobileNoChanged,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Mobile number is required';
                }
                if (value.length < 10) {
                  return 'Please enter a valid mobile number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Joining Date
            DatePickerField(
              label: 'Joining Date',
              hint: 'Select joining date',
              value: widget.joiningDate,
              onChanged: widget.onJoiningDateChanged,
              firstDate: DateTime(2000),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              validator: (value) {
                if (value == null) {
                  return 'Please select joining date';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Subjects (if teacher)
            if (widget.categoryLabel == 'Teachers') ...[
              _SubjectSelector(
                label: "Subject's",
                hint: 'Select subjects',
                selectedSubjects: widget.selectedSubjects,
                onAddSubject: () => _showSubjectSelector(context),
                onRemoveSubject: widget.onSubjectRemoved,
              ),
              const SizedBox(height: 16),
            ],

            // Gender
            BottomSheetDropdown<String>(
              label: 'Gender',
              hint: 'Select Gender',
              items: widget.genders,
              value: widget.selectedGender,
              onChanged: widget.onGenderChanged,
              validator: (value) {
                if (value == null) {
                  return 'Please select gender';
                }
                return null;
              },
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
              hint: 'Enter address',
              icon: Icons.location_on_outlined,
              maxLines: 1,
              onChanged: widget.onAddressChanged,
            ),
            const SizedBox(height: 16),

            // Email
            IconFormField(
              controller: _emailController,
              label: 'Email',
              hint: 'Enter your Email',
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              onChanged: widget.onEmailChanged,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Employee ID (auto-generated)
            IconFormField(
              controller: _employeeIdController,
              label:
                  '${widget.categoryLabel == 'Teachers' ? 'Teacher' : 'Employee'} ID (Auto Generated)',
              hint:
                  'Enter ${widget.categoryLabel == 'Teachers' ? 'Teacher' : 'Employee'} ID',
              icon: Icons.badge_outlined,
              enabled: false,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// Subject selector widget with chips.
class _SubjectSelector extends StatelessWidget {
  const _SubjectSelector({
    required this.label,
    required this.hint,
    required this.selectedSubjects,
    required this.onAddSubject,
    required this.onRemoveSubject,
  });

  final String label;
  final String hint;
  final List<String> selectedSubjects;
  final VoidCallback onAddSubject;
  final ValueChanged<String> onRemoveSubject;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onAddSubject,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.menu_book_outlined,
                  color: AppColors.iconDefault,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: selectedSubjects.isEmpty
                      ? Text(hint, style: AppTextStyles.hint)
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: selectedSubjects
                              .map(
                                (subject) => _SubjectChip(
                                  label: subject,
                                  onRemove: () => onRemoveSubject(subject),
                                ),
                              )
                              .toList(),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Individual subject chip widget.
class _SubjectChip extends StatelessWidget {
  const _SubjectChip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRemove,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.close, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet for selecting subjects with improved design.
class _SubjectSelectorBottomSheet extends StatefulWidget {
  const _SubjectSelectorBottomSheet({
    required this.subjects,
    required this.onSubjectSelected,
  });

  final List<String> subjects;
  final ValueChanged<String> onSubjectSelected;

  @override
  State<_SubjectSelectorBottomSheet> createState() =>
      _SubjectSelectorBottomSheetState();
}

class _SubjectSelectorBottomSheetState
    extends State<_SubjectSelectorBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredSubjects = [];

  @override
  void initState() {
    super.initState();
    _filteredSubjects = widget.subjects;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterSubjects(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSubjects = widget.subjects;
      } else {
        _filteredSubjects = widget.subjects
            .where((s) => s.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  'Select Subject',
                  style: AppTextStyles.heading4.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose a subject to add',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: _filterSubjects,
              decoration: InputDecoration(
                hintText: 'Search subjects...',
                hintStyle: AppTextStyles.hint,
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.iconDefault,
                  size: 20,
                ),
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
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
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
          ),
          const SizedBox(height: 16),

          // Subject list
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.35,
            ),
            child: _filteredSubjects.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color: AppColors.iconDefault,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No subjects found',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: _filteredSubjects.length,
                    itemBuilder: (context, index) {
                      final subject = _filteredSubjects[index];
                      return InkWell(
                        onTap: () => widget.onSubjectSelected(subject),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.secondary.withAlpha(30),
                                      AppColors.primary.withAlpha(30),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.menu_book_outlined,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  subject,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.add_circle_outline,
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
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
