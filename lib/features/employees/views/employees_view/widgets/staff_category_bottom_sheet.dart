import 'package:flutter/material.dart';
import 'package:school_management_system/shared/styles/app_styles.dart';

import '../../../blocs/create_employee/create_employee_state.dart';

/// Dialog for selecting staff category in the employees view.
class StaffCategorySelectorDialog extends StatefulWidget {
  const StaffCategorySelectorDialog({
    super.key,
    required this.categories,
    required this.onCategorySelected,
    required this.onAddCategory,
  });

  final List<StaffCategoryModel> categories;
  final void Function(StaffCategoryModel) onCategorySelected;
  final void Function(String) onAddCategory;

  /// Shows the staff category selector dialog.
  static Future<StaffCategoryModel?> show({
    required BuildContext context,
    required List<StaffCategoryModel> categories,
    required void Function(StaffCategoryModel) onCategorySelected,
    required void Function(String) onAddCategory,
  }) {
    return showDialog<StaffCategoryModel>(
      context: context,
      builder: (context) => StaffCategorySelectorDialog(
        categories: categories,
        onCategorySelected: onCategorySelected,
        onAddCategory: onAddCategory,
      ),
    );
  }

  @override
  State<StaffCategorySelectorDialog> createState() =>
      _StaffCategorySelectorDialogState();
}

class _StaffCategorySelectorDialogState
    extends State<StaffCategorySelectorDialog> {
  bool _isAddingNew = false;
  final _newCategoryController = TextEditingController();
  late List<StaffCategoryModel> _categories;

  @override
  void initState() {
    super.initState();
    _categories = List.from(widget.categories);
  }

  @override
  void dispose() {
    _newCategoryController.dispose();
    super.dispose();
  }

  void _handleAddNew() {
    final name = _newCategoryController.text.trim();
    if (name.isNotEmpty) {
      final newCategory = StaffCategoryModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        isCustom: true,
      );
      widget.onAddCategory(name);
      setState(() {
        _categories.add(newCategory);
        _isAddingNew = false;
      });
      _newCategoryController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Choose Staff Category',
              style: AppTextStyles.heading4.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Select The Employee's Type To Continue With The Registration.",
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),

            // Category list
            ..._categories.map(
              (category) => _CategoryTile(
                category: category,
                onTap: () {
                  widget.onCategorySelected(category);
                  Navigator.pop(context, category);
                },
              ),
            ),

            // Add new category section
            if (_isAddingNew)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newCategoryController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Enter category name',
                          hintStyle: AppTextStyles.hint,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                        onSubmitted: (_) => _handleAddNew(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _handleAddNew,
                      icon: const Icon(Icons.check, color: AppColors.green),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isAddingNew = false;
                          _newCategoryController.clear();
                        });
                      },
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.borderError,
                      ),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isAddingNew = true;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 24),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Individual category tile widget.
class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.onTap});

  final StaffCategoryModel category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                category.name,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (category.isCustom)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Custom',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
