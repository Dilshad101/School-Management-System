import 'package:flutter/material.dart';

import '../../styles/app_styles.dart';

/// A reusable, production-ready filter dropdown widget.
///
/// Features:
/// - Generic type support for any data type
/// - Internal state management with ValueNotifier
/// - Custom item builder for flexible rendering
/// - Loading and disabled states
/// - Customizable styling
/// - Accessibility support
/// - Form validation support
class FilterDropdown<T> extends StatefulWidget {
  const FilterDropdown({
    super.key,
    required this.items,
    this.initialValue,
    this.value,
    this.onChanged,
    this.controller,
    this.labelBuilder,
    this.hintText,
    this.label,
    this.isLoading = false,
    this.isEnabled = true,
    this.isExpanded = false,
    this.showBorder = true,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.padding,
    this.icon,
    this.iconSize = 20,
    this.style,
    this.hintStyle,
    this.dropdownColor,
    this.elevation = 2,
    this.menuMaxHeight,
    this.validator,
    this.autovalidateMode,
    this.focusNode,
    this.semanticLabel,
  }) : assert(
         value == null || controller == null,
         'Cannot provide both value and controller. Use one or the other.',
       );

  /// List of items to display in the dropdown
  final List<T> items;

  /// Initial value when using internal state management
  final T? initialValue;

  /// Externally controlled value (use this OR controller, not both)
  final T? value;

  /// Callback when selection changes
  final ValueChanged<T?>? onChanged;

  /// Controller for external state management with ValueNotifier
  final FilterDropdownController<T>? controller;

  /// Custom builder to convert item to display string
  final String Function(T item)? labelBuilder;

  /// Hint text when no value is selected
  final String? hintText;

  /// Optional label displayed above the dropdown
  final String? label;

  /// Shows loading indicator when true
  final bool isLoading;

  /// Enables/disables the dropdown
  final bool isEnabled;

  /// Whether the dropdown should expand to fill available width
  final bool isExpanded;

  /// Whether to show border around the dropdown
  final bool showBorder;

  /// Background color of the dropdown button
  final Color? backgroundColor;

  /// Border color when showBorder is true
  final Color? borderColor;

  /// Border radius of the dropdown button
  final BorderRadius? borderRadius;

  /// Internal padding of the dropdown button
  final EdgeInsetsGeometry? padding;

  /// Custom dropdown icon
  final Widget? icon;

  /// Size of the dropdown icon
  final double iconSize;

  /// Text style for selected item
  final TextStyle? style;

  /// Text style for hint text
  final TextStyle? hintStyle;

  /// Background color of the dropdown menu
  final Color? dropdownColor;

  /// Elevation of the dropdown menu
  final int elevation;

  /// Maximum height of the dropdown menu
  final double? menuMaxHeight;

  /// Validator function for form validation
  final String? Function(T?)? validator;

  /// Auto-validate mode for form validation
  final AutovalidateMode? autovalidateMode;

  /// Focus node for keyboard navigation
  final FocusNode? focusNode;

  /// Semantic label for accessibility
  final String? semanticLabel;

  @override
  State<FilterDropdown<T>> createState() => _FilterDropdownState<T>();
}

class _FilterDropdownState<T> extends State<FilterDropdown<T>> {
  late FilterDropdownController<T> _controller;
  bool _isInternalController = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    if (widget.controller != null) {
      _controller = widget.controller!;
      _isInternalController = false;
    } else {
      _controller = FilterDropdownController<T>(
        widget.value ?? widget.initialValue,
      );
      _isInternalController = true;
    }
  }

  @override
  void didUpdateWidget(covariant FilterDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle controller change
    if (widget.controller != oldWidget.controller) {
      if (_isInternalController) {
        _controller.dispose();
      }
      _initController();
    }

    // Handle external value change
    if (widget.value != oldWidget.value && widget.value != _controller.value) {
      _controller.value = widget.value;
    }
  }

  @override
  void dispose() {
    if (_isInternalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  String _getItemLabel(T item) {
    return widget.labelBuilder?.call(item) ?? item.toString();
  }

  void _handleValueChanged(T? newValue) {
    _controller.value = newValue;
    widget.onChanged?.call(newValue);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor =
        widget.backgroundColor ?? Colors.transparent;
    final effectiveBorderColor = widget.borderColor ?? Colors.transparent;
    final effectiveBorderRadius =
        widget.borderRadius ?? BorderRadius.circular(8);
    final effectivePadding =
        widget.padding ?? const EdgeInsets.symmetric(horizontal: 10);
    final effectiveStyle = widget.style ?? AppTextStyles.bodySmall;
    final effectiveHintStyle =
        widget.hintStyle ??
        AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary);
    final effectiveDropdownColor = widget.dropdownColor ?? Colors.white;

    return ValueListenableBuilder<T?>(
      valueListenable: _controller,
      builder: (context, currentValue, _) {
        Widget dropdownWidget = _buildDropdown(
          context,
          currentValue: currentValue,
          effectiveBackgroundColor: effectiveBackgroundColor,
          effectiveBorderColor: effectiveBorderColor,
          effectiveBorderRadius: effectiveBorderRadius,
          effectivePadding: effectivePadding,
          effectiveStyle: effectiveStyle,
          effectiveHintStyle: effectiveHintStyle,
          effectiveDropdownColor: effectiveDropdownColor,
        );

        // Wrap with semantics for accessibility
        if (widget.semanticLabel != null) {
          dropdownWidget = Semantics(
            label: widget.semanticLabel,
            button: true,
            enabled: widget.isEnabled && !widget.isLoading,
            child: dropdownWidget,
          );
        }

        // Add label if provided
        if (widget.label != null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label!,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              dropdownWidget,
            ],
          );
        }

        return dropdownWidget;
      },
    );
  }

  Widget _buildDropdown(
    BuildContext context, {
    required T? currentValue,
    required Color effectiveBackgroundColor,
    required Color effectiveBorderColor,
    required BorderRadius effectiveBorderRadius,
    required EdgeInsetsGeometry effectivePadding,
    required TextStyle effectiveStyle,
    required TextStyle effectiveHintStyle,
    required Color effectiveDropdownColor,
  }) {
    // Use FormField for validation support
    if (widget.validator != null) {
      return FormField<T>(
        initialValue: currentValue,
        validator: widget.validator,
        autovalidateMode: widget.autovalidateMode ?? AutovalidateMode.disabled,
        builder: (FormFieldState<T> state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDropdownContainer(
                context,
                currentValue: currentValue,
                effectiveBackgroundColor: effectiveBackgroundColor,
                effectiveBorderColor: state.hasError
                    ? AppColors.borderError
                    : effectiveBorderColor,
                effectiveBorderRadius: effectiveBorderRadius,
                effectivePadding: effectivePadding,
                effectiveStyle: effectiveStyle,
                effectiveHintStyle: effectiveHintStyle,
                effectiveDropdownColor: effectiveDropdownColor,
                onChangedOverride: (newValue) {
                  state.didChange(newValue);
                  _handleValueChanged(newValue);
                },
              ),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 12),
                  child: Text(
                    state.errorText!,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.borderError,
                    ),
                  ),
                ),
            ],
          );
        },
      );
    }

    return _buildDropdownContainer(
      context,
      currentValue: currentValue,
      effectiveBackgroundColor: effectiveBackgroundColor,
      effectiveBorderColor: effectiveBorderColor,
      effectiveBorderRadius: effectiveBorderRadius,
      effectivePadding: effectivePadding,
      effectiveStyle: effectiveStyle,
      effectiveHintStyle: effectiveHintStyle,
      effectiveDropdownColor: effectiveDropdownColor,
    );
  }

  Widget _buildDropdownContainer(
    BuildContext context, {
    required T? currentValue,
    required Color effectiveBackgroundColor,
    required Color effectiveBorderColor,
    required BorderRadius effectiveBorderRadius,
    required EdgeInsetsGeometry effectivePadding,
    required TextStyle effectiveStyle,
    required TextStyle effectiveHintStyle,
    required Color effectiveDropdownColor,
    ValueChanged<T?>? onChangedOverride,
  }) {
    final isDisabled = !widget.isEnabled || widget.isLoading;

    return Container(
      decoration: BoxDecoration(
        color: isDisabled
            ? effectiveBackgroundColor.withAlpha(150)
            : effectiveBackgroundColor,
        borderRadius: effectiveBorderRadius,
        border: widget.showBorder
            ? Border.all(color: effectiveBorderColor)
            : null,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: currentValue,
          items: _buildItems(effectiveStyle),
          onChanged: isDisabled
              ? null
              : (onChangedOverride ?? _handleValueChanged),
          hint: widget.hintText != null
              ? Text(widget.hintText!, style: effectiveHintStyle)
              : null,
          isExpanded: widget.isExpanded,
          dropdownColor: effectiveDropdownColor,
          elevation: widget.elevation,
          menuMaxHeight: widget.menuMaxHeight,
          focusNode: widget.focusNode,
          borderRadius: effectiveBorderRadius,
          padding: effectivePadding,
          icon: _buildIcon(isDisabled),
          iconSize: widget.iconSize,
          style: effectiveStyle.copyWith(
            color: isDisabled ? AppColors.textSecondary : null,
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<T>> _buildItems(TextStyle style) {
    return widget.items.map((T item) {
      return DropdownMenuItem<T>(
        value: item,
        child: Text(_getItemLabel(item), style: style),
      );
    }).toList();
  }

  Widget _buildIcon(bool isDisabled) {
    if (widget.isLoading) {
      return SizedBox(
        width: widget.iconSize,
        height: widget.iconSize,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return widget.icon ??
        Icon(
          Icons.keyboard_arrow_down_rounded,
          size: widget.iconSize,
          color: isDisabled ? AppColors.textSecondary : AppColors.textPrimary,
        );
  }
}

/// Controller for managing FilterDropdown state externally
///
/// Use this when you need to:
/// - Access or modify the selected value from outside the widget
/// - Share state between multiple widgets
/// - Reset the selection programmatically
class FilterDropdownController<T> extends ValueNotifier<T?> {
  FilterDropdownController([T? initialValue]) : super(initialValue);

  /// Clears the current selection
  void clear() => value = null;

  /// Checks if a value is selected
  bool get hasValue => value != null;
}

/// Extension to create FilterDropdown from enum values
extension FilterDropdownEnumExtension<T extends Enum> on List<T> {
  /// Creates dropdown items from enum values with custom label formatting
  List<T> toDropdownItems() => this;
}
