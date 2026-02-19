import 'package:flutter/material.dart';
import 'package:school_management_system/shared/styles/app_styles.dart';
import 'package:school_management_system/shared/widgets/dropdowns/bottom_sheet_dropdown.dart';

import '../../../../../features/students/views/create_student_view/widgets/date_picker_field.dart';
import '../../../../../features/students/views/create_student_view/widgets/icon_form_field.dart';
import '../../../blocs/create_employee/create_employee_state.dart';

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
    required this.roles,
    required this.selectedRoles,
    required this.onRoleAdded,
    required this.onRoleRemoved,
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
  final List<SubjectModel> selectedSubjects;
  final String? selectedGender;
  final String? selectedBloodGroup;
  final String address;
  final String email;
  final String employeeId;
  final List<SubjectModel> subjects;
  final List<String> genders;
  final List<String> bloodGroups;
  final List<RoleModel> roles;
  final List<RoleModel> selectedRoles;
  final ValueChanged<RoleModel> onRoleAdded;
  final ValueChanged<RoleModel> onRoleRemoved;
  final ValueChanged<String> onFullNameChanged;
  final ValueChanged<String> onMobileNoChanged;
  final ValueChanged<DateTime?> onJoiningDateChanged;
  final ValueChanged<SubjectModel> onSubjectAdded;
  final ValueChanged<SubjectModel> onSubjectRemoved;
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
        .where((s) => !widget.selectedSubjects.any((ss) => ss.id == s.id))
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
      builder: (context) => _ItemSelectorBottomSheet<SubjectModel>(
        title: 'Select Subject',
        subtitle: 'Choose a subject to add',
        items: availableSubjects,
        itemLabelBuilder: (item) => item.name,
        onItemSelected: (subject) {
          widget.onSubjectAdded(subject);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showRoleSelector(BuildContext context) {
    final availableRoles = widget.roles
        .where((r) => !widget.selectedRoles.any((sr) => sr.id == r.id))
        .toList();

    if (availableRoles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All roles have been selected')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ItemSelectorBottomSheet<RoleModel>(
        title: 'Select Role',
        subtitle: 'Choose a role to add',
        items: availableRoles,
        itemLabelBuilder: (item) => item.name,
        onItemSelected: (role) {
          widget.onRoleAdded(role);
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

            // Roles (Multiple selection)
            _MultiSelectField<RoleModel>(
              label: 'Role(s)',
              hint: 'Select roles',
              icon: Icons.work_outline,
              selectedItems: widget.selectedRoles,
              itemLabelBuilder: (item) => item.name,
              onAddItem: () => _showRoleSelector(context),
              onRemoveItem: widget.onRoleRemoved,
              validator: (items) {
                if (items.isEmpty) {
                  return 'Please select at least one role';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

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

            // Subjects (always visible)
            _MultiSelectField<SubjectModel>(
              label: "Subject's",
              hint: 'Select subjects',
              icon: Icons.menu_book_outlined,
              selectedItems: widget.selectedSubjects,
              itemLabelBuilder: (item) => item.name,
              onAddItem: () => _showSubjectSelector(context),
              onRemoveItem: widget.onSubjectRemoved,
            ),
            const SizedBox(height: 16),

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
              label: 'Employee ID (Auto Generated)',
              hint: 'Enter Employee ID',
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

/// Generic multi-select field widget with chips.
class _MultiSelectField<T> extends FormField<List<T>> {
  _MultiSelectField({
    super.key,
    required String label,
    required String hint,
    required IconData icon,
    required List<T> selectedItems,
    required String Function(T) itemLabelBuilder,
    required VoidCallback onAddItem,
    required ValueChanged<T> onRemoveItem,
    String? Function(List<T>)? validator,
  }) : super(
         initialValue: selectedItems,
         validator: validator != null
             ? (value) => validator(value ?? [])
             : null,
         autovalidateMode: AutovalidateMode.onUserInteraction,
         builder: (FormFieldState<List<T>> state) {
           // Sync with external state
           if (state.value != selectedItems) {
             WidgetsBinding.instance.addPostFrameCallback((_) {
               state.didChange(selectedItems);
             });
           }

           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text(label, style: AppTextStyles.labelMedium),
               const SizedBox(height: 8),
               GestureDetector(
                 onTap: onAddItem,
                 child: Container(
                   width: double.infinity,
                   padding: const EdgeInsets.symmetric(
                     horizontal: 16,
                     vertical: 12,
                   ),
                   decoration: BoxDecoration(
                     color: AppColors.cardBackground,
                     borderRadius: BorderRadius.circular(12),
                     border: Border.all(
                       color: state.hasError
                           ? AppColors.borderError
                           : AppColors.border,
                       width: 1,
                     ),
                   ),
                   child: Row(
                     children: [
                       Icon(icon, color: AppColors.iconDefault, size: 20),
                       const SizedBox(width: 12),
                       Expanded(
                         child: selectedItems.isEmpty
                             ? Text(hint, style: AppTextStyles.hint)
                             : Wrap(
                                 spacing: 8,
                                 runSpacing: 8,
                                 children: selectedItems
                                     .map(
                                       (item) => _ItemChip(
                                         label: itemLabelBuilder(item),
                                         onRemove: () => onRemoveItem(item),
                                       ),
                                     )
                                     .toList(),
                               ),
                       ),
                     ],
                   ),
                 ),
               ),
               if (state.hasError)
                 Padding(
                   padding: const EdgeInsets.only(top: 8, left: 12),
                   child: Text(
                     state.errorText ?? '',
                     style: AppTextStyles.caption.copyWith(
                       color: AppColors.borderError,
                     ),
                   ),
                 ),
             ],
           );
         },
       );
}

/// Individual item chip widget.
class _ItemChip extends StatelessWidget {
  const _ItemChip({required this.label, required this.onRemove});

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

/// Generic bottom sheet for selecting items with search.
class _ItemSelectorBottomSheet<T> extends StatefulWidget {
  const _ItemSelectorBottomSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.items,
    required this.itemLabelBuilder,
    required this.onItemSelected,
  });

  final String title;
  final String subtitle;
  final List<T> items;
  final String Function(T) itemLabelBuilder;
  final ValueChanged<T> onItemSelected;

  @override
  State<_ItemSelectorBottomSheet<T>> createState() =>
      _ItemSelectorBottomSheetState<T>();
}

class _ItemSelectorBottomSheetState<T>
    extends State<_ItemSelectorBottomSheet<T>> {
  final TextEditingController _searchController = TextEditingController();
  List<T> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items
            .where(
              (item) => widget
                  .itemLabelBuilder(item)
                  .toLowerCase()
                  .contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  widget.title,
                  style: AppTextStyles.heading4.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.subtitle,
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
              onChanged: _filterItems,
              decoration: InputDecoration(
                hintText: 'Search...',
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

          // Item list
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.35,
            ),
            child: _filteredItems.isEmpty
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
                          'No items found',
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
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      return InkWell(
                        onTap: () => widget.onItemSelected(item),
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
                                  Icons.check_circle_outline,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  widget.itemLabelBuilder(item),
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
