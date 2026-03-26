import 'package:flutter/material.dart';

import '../../../../../../../core/utils/di.dart';
import '../../../../../../../shared/styles/app_styles.dart';
import '../../../../../../../shared/widgets/buttons/gradient_button.dart';
import '../../../../../../../shared/widgets/input_fields/suggestion_form_field.dart';
import '../../../../../../class/models/classroom_model.dart'
    hide AcademicYearModel;
import '../../../../../../class/repositories/classroom_repository.dart';
import '../../../../../models/academic_year_model.dart';
import '../../../../../models/fee_component_model.dart';
import '../../../../../repositories/academic_year_repository.dart';
import '../../../../../repositories/fee_component_repository.dart';

/// Result model for fee component item with amount.
class FeeComponentItem {
  final String componentId;
  final String componentName;
  final String amount;

  FeeComponentItem({
    required this.componentId,
    required this.componentName,
    required this.amount,
  });
}

/// Result returned from the CreateFeeStructureBottomSheet.
class CreateFeeStructureResult {
  final String name;
  final String classroomId;
  final String academicYearId;
  final List<FeeComponentItem> items;

  CreateFeeStructureResult({
    required this.name,
    required this.classroomId,
    required this.academicYearId,
    required this.items,
  });
}

/// Bottom sheet for creating or editing a fee structure.
class CreateFeeStructureBottomSheet extends StatefulWidget {
  final String schoolId;
  final String? initialName;
  final String? initialClassroomId;
  final String? initialClassroomName;
  final String? initialAcademicYearId;
  final String? initialAcademicYearName;
  final List<FeeComponentItem>? initialItems;
  final bool isEditing;

  const CreateFeeStructureBottomSheet({
    super.key,
    required this.schoolId,
    this.initialName,
    this.initialClassroomId,
    this.initialClassroomName,
    this.initialAcademicYearId,
    this.initialAcademicYearName,
    this.initialItems,
    this.isEditing = false,
  });

  /// Shows the bottom sheet and returns the result.
  static Future<CreateFeeStructureResult?> show(
    BuildContext context, {
    required String schoolId,
    String? initialName,
    String? initialClassroomId,
    String? initialClassroomName,
    String? initialAcademicYearId,
    String? initialAcademicYearName,
    List<FeeComponentItem>? initialItems,
    bool isEditing = false,
  }) {
    return showModalBottomSheet<CreateFeeStructureResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CreateFeeStructureBottomSheet(
        schoolId: schoolId,
        initialName: initialName,
        initialClassroomId: initialClassroomId,
        initialClassroomName: initialClassroomName,
        initialAcademicYearId: initialAcademicYearId,
        initialAcademicYearName: initialAcademicYearName,
        initialItems: initialItems,
        isEditing: isEditing,
      ),
    );
  }

  @override
  State<CreateFeeStructureBottomSheet> createState() =>
      _CreateFeeStructureBottomSheetState();
}

class _CreateFeeStructureBottomSheetState
    extends State<CreateFeeStructureBottomSheet> {
  final _nameController = TextEditingController();
  final _classroomController = TextEditingController();
  final _academicYearController = TextEditingController();
  final _componentController = TextEditingController();
  final _amountController = TextEditingController();

  String? _selectedClassroomId;
  String? _selectedAcademicYearId;
  String? _selectedComponentId;
  String? _selectedComponentName;

  final List<FeeComponentItem> _feeItems = [];

  late final ClassroomRepository _classroomRepository;
  late final AcademicYearRepository _academicYearRepository;
  late final FeeComponentRepository _feeComponentRepository;

  @override
  void initState() {
    super.initState();
    _classroomRepository = locator<ClassroomRepository>();
    _academicYearRepository = locator<AcademicYearRepository>();
    _feeComponentRepository = locator<FeeComponentRepository>();

    if (widget.initialName != null) {
      _nameController.text = widget.initialName!;
    }
    if (widget.initialClassroomId != null) {
      _selectedClassroomId = widget.initialClassroomId;
      _classroomController.text = widget.initialClassroomName ?? '';
    }
    if (widget.initialAcademicYearId != null) {
      _selectedAcademicYearId = widget.initialAcademicYearId;
      _academicYearController.text = widget.initialAcademicYearName ?? '';
    }
    if (widget.initialItems != null) {
      _feeItems.addAll(widget.initialItems!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _classroomController.dispose();
    _academicYearController.dispose();
    _componentController.dispose();
    _amountController.dispose();
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
                  widget.isEditing
                      ? 'Edit Fee Structure'
                      : 'Create Fee Structure',
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
            const SizedBox(height: 24),

            // Fee Name Field
            _buildLabel('Fee Name'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _nameController,
              hintText: 'Enter fee name',
            ),
            const SizedBox(height: 16),

            // Select Class (Suggestion Field)
            SuggestionFormField<ClassroomModel>(
              controller: _classroomController,
              label: 'Select Class',
              hint: 'Search and select class',
              isRequired: true,
              suggestionsCallback: _searchClassrooms,
              itemBuilder: (context, classroom) {
                return ListTile(
                  title: Text(classroom.name),
                  subtitle: Text(classroom.code),
                  dense: true,
                );
              },
              onSelected: (classroom) {
                _selectedClassroomId = classroom.id;
                _classroomController.text = classroom.name;
              },
            ),
            const SizedBox(height: 16),

            // Select Academic Year (Suggestion Field)
            SuggestionFormField<AcademicYearModel>(
              controller: _academicYearController,
              label: 'Select Academic Year',
              hint: 'Search and select academic year',
              isRequired: true,
              suggestionsCallback: _searchAcademicYears,
              itemBuilder: (context, academicYear) {
                return ListTile(
                  title: Text(academicYear.name),
                  subtitle: Text(
                    '${academicYear.formattedStartDate} - ${academicYear.formattedEndDate}',
                  ),
                  trailing: academicYear.isCurrent
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Current',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.green,
                            ),
                          ),
                        )
                      : null,
                  dense: true,
                );
              },
              onSelected: (academicYear) {
                _selectedAcademicYearId = academicYear.id;
                _academicYearController.text = academicYear.name;
              },
            ),
            const SizedBox(height: 16),

            // Fee Component Section
            _buildLabel('Fee Components (Optional)'),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Component Suggestion Field
                Expanded(
                  flex: 2,
                  child: SuggestionFormField<FeeComponentModel>(
                    controller: _componentController,
                    label: '',
                    hint: 'Search component',
                    suggestionsCallback: _searchFeeComponents,
                    itemBuilder: (context, component) {
                      return ListTile(
                        title: Text(component.name),
                        subtitle: Text(component.frequency.displayName),
                        trailing: Text(
                          component.typeDisplayName,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: component.isOptional
                                ? AppColors.textSecondary
                                : AppColors.green,
                          ),
                        ),
                        dense: true,
                      );
                    },
                    onSelected: (component) {
                      _selectedComponentId = component.id;
                      _selectedComponentName = component.name;
                      _componentController.text = component.name;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Amount Field
                Expanded(
                  flex: 1,
                  child: _buildTextField(
                    controller: _amountController,
                    hintText: 'Amount',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                // Add Button
                InkWell(
                  onTap: _addFeeComponent,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Added Fee Components List
            if (_feeItems.isNotEmpty) ...[
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: _feeItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: index < _feeItems.length - 1
                            ? Border(
                                bottom: BorderSide(color: AppColors.border),
                              )
                            : null,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.componentName,
                              style: AppTextStyles.bodyMedium,
                            ),
                          ),
                          Text(
                            '₹${item.amount}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => _removeFeeComponent(index),
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.close,
                                size: 18,
                                color: AppColors.borderError,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 8),

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
                    label: 'Save Fee Structure',
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  Future<List<ClassroomModel>> _searchClassrooms(String query) async {
    try {
      final response = await _classroomRepository.getClassrooms(
        page: 1,
        pageSize: 10,
        search: query,
      );
      return response.results;
    } catch (e) {
      return [];
    }
  }

  Future<List<AcademicYearModel>> _searchAcademicYears(String query) async {
    try {
      final response = await _academicYearRepository.getAcademicYears(
        page: 1,
        pageSize: 10,
        search: query,
      );
      return response.results;
    } catch (e) {
      return [];
    }
  }

  Future<List<FeeComponentModel>> _searchFeeComponents(String query) async {
    try {
      final response = await _feeComponentRepository.getFeeComponents(
        page: 1,
        pageSize: 10,
        search: query,
      );
      return response.results;
    } catch (e) {
      return [];
    }
  }

  void _addFeeComponent() {
    if (_selectedComponentId == null || _selectedComponentName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a fee component')),
      );
      return;
    }

    final amount = _amountController.text.trim();
    if (amount.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter an amount')));
      return;
    }

    // Check if component already added
    final exists = _feeItems.any(
      (item) => item.componentId == _selectedComponentId,
    );
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This component is already added')),
      );
      return;
    }

    setState(() {
      _feeItems.add(
        FeeComponentItem(
          componentId: _selectedComponentId!,
          componentName: _selectedComponentName!,
          amount: amount,
        ),
      );
      _componentController.clear();
      _amountController.clear();
      _selectedComponentId = null;
      _selectedComponentName = null;
    });
  }

  void _removeFeeComponent(int index) {
    setState(() {
      _feeItems.removeAt(index);
    });
  }

  void _onSubmit() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a fee name')));
      return;
    }

    if (_selectedClassroomId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a class')));
      return;
    }

    if (_selectedAcademicYearId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an academic year')),
      );
      return;
    }

    Navigator.pop(
      context,
      CreateFeeStructureResult(
        name: name,
        classroomId: _selectedClassroomId!,
        academicYearId: _selectedAcademicYearId!,
        items: _feeItems,
      ),
    );
  }
}
