import 'package:flutter/material.dart';
import 'package:school_management_system/shared/styles/app_styles.dart';

/// A form field that opens a bottom sheet for selection.
/// This provides a more user-friendly experience on mobile devices.
class BottomSheetDropdown<T> extends StatefulWidget {
  const BottomSheetDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    required this.value,
    required this.onChanged,
    this.itemLabelBuilder,
    this.searchable = false,
    this.validator,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });

  final String label;
  final String hint;
  final List<T> items;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String Function(T)? itemLabelBuilder;
  final bool searchable;
  final String? Function(T?)? validator;
  final AutovalidateMode autovalidateMode;

  @override
  State<BottomSheetDropdown<T>> createState() => _BottomSheetDropdownState<T>();
}

class _BottomSheetDropdownState<T> extends State<BottomSheetDropdown<T>> {
  final _formFieldKey = GlobalKey<FormFieldState<T>>();

  String _getItemLabel(T item) {
    return widget.itemLabelBuilder?.call(item) ?? item.toString();
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BottomSheetContent<T>(
        title: widget.label,
        items: widget.items,
        selectedValue: widget.value,
        onItemSelected: (item) {
          widget.onChanged(item);
          // Update form field state and revalidate
          _formFieldKey.currentState?.didChange(item);
          Navigator.pop(context);
        },
        itemLabelBuilder: widget.itemLabelBuilder,
        searchable: widget.searchable,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        FormField<T>(
          key: _formFieldKey,
          initialValue: widget.value,
          validator: widget.validator,
          autovalidateMode: widget.autovalidateMode,
          builder: (FormFieldState<T> state) {
            // Sync the form field value with the widget value
            if (state.value != widget.value) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                state.didChange(widget.value);
              });
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _showBottomSheet(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
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
                        Expanded(
                          child: Text(
                            widget.value != null
                                ? _getItemLabel(widget.value as T)
                                : widget.hint,
                            style: widget.value != null
                                ? AppTextStyles.bodyMedium
                                : AppTextStyles.hint,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
                if (state.hasError) ...[
                  const SizedBox(height: 8),
                  Text(
                    state.errorText!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.borderError,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _BottomSheetContent<T> extends StatefulWidget {
  const _BottomSheetContent({
    required this.title,
    required this.items,
    required this.selectedValue,
    required this.onItemSelected,
    this.itemLabelBuilder,
    this.searchable = false,
  });

  final String title;
  final List<T> items;
  final T? selectedValue;
  final ValueChanged<T> onItemSelected;
  final String Function(T)? itemLabelBuilder;
  final bool searchable;

  @override
  State<_BottomSheetContent<T>> createState() => _BottomSheetContentState<T>();
}

class _BottomSheetContentState<T> extends State<_BottomSheetContent<T>> {
  late List<T> _filteredItems;
  final _searchController = TextEditingController();

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

  String _getItemLabel(T item) {
    return widget.itemLabelBuilder?.call(item) ?? item.toString();
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items
            .where(
              (item) => _getItemLabel(
                item,
              ).toLowerCase().contains(query.toLowerCase()),
            )
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
                  child: Text(
                    'Select ${widget.title}',
                    style: AppTextStyles.heading4,
                  ),
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
          // Search field (if searchable)
          if (widget.searchable) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                onChanged: _filterItems,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: AppTextStyles.hint,
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
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
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          const Divider(height: 1),
          // Items list
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.only(bottom: bottomPadding + 16),
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                final item = _filteredItems[index];
                final isSelected = item == widget.selectedValue;

                return InkWell(
                  onTap: () => widget.onItemSelected(item),
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
                        Expanded(
                          child: Text(
                            _getItemLabel(item),
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
