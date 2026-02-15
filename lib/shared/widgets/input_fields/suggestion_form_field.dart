import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:school_management_system/shared/styles/app_styles.dart';

/// A reusable suggestion form field with autocomplete functionality
/// using flutter_typeahead package. Matches the design of CustomFormField
/// and SimpleFormField with extensive customization options.
class SuggestionFormField<T> extends StatelessWidget {
  const SuggestionFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.suggestionsCallback,
    required this.itemBuilder,
    required this.onSelected,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.isRequired = false,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.maxLines = 1,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.emptyBuilder,
    this.errorBuilder,
    this.loadingBuilder,
    this.minCharsForSuggestions = 0,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.hideOnEmpty = false,
    this.hideOnLoading = false,
    this.hideOnError = false,
    this.animationDuration = const Duration(milliseconds: 200),
    this.suggestionsBoxDecoration,
    this.itemSeparatorBuilder,
    this.scrollController,
    this.noItemsFoundBuilder,
    this.hideKeyboardOnDrag = false,
  });

  // Core fields
  final TextEditingController controller;
  final String label;
  final String hint;

  // Typeahead callbacks
  final Future<List<T>> Function(String) suggestionsCallback;
  final Widget Function(BuildContext, T) itemBuilder;
  final void Function(T) onSelected;

  // Validation and change handling
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  // Field properties
  final bool enabled;
  final bool isRequired;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final int maxLines;
  final AutovalidateMode autovalidateMode;

  // Suggestions box customization
  final Widget Function(BuildContext)? emptyBuilder;
  final Widget Function(BuildContext, Object?)? errorBuilder;
  final Widget Function(BuildContext)? loadingBuilder;
  final Widget Function(BuildContext)? noItemsFoundBuilder;
  final int minCharsForSuggestions;
  final Duration debounceDuration;
  final bool hideOnEmpty;
  final bool hideOnLoading;
  final bool hideOnError;
  final Duration animationDuration;
  final BoxDecoration? suggestionsBoxDecoration;
  final Widget Function(BuildContext, int)? itemSeparatorBuilder;
  final ScrollController? scrollController;
  final bool hideKeyboardOnDrag;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with optional required indicator
        Text.rich(
          TextSpan(
            text: label,
            style: AppTextStyles.labelMedium,
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // TypeAheadField
        TypeAheadField<T>(
          controller: controller,
          hideOnEmpty: hideOnEmpty,
          hideOnLoading: hideOnLoading,
          hideOnError: hideOnError,
          debounceDuration: debounceDuration,
          animationDuration: animationDuration,
          scrollController: scrollController,
          hideKeyboardOnDrag: hideKeyboardOnDrag,

          // Suggestions configuration
          suggestionsCallback: (pattern) async {
            if (pattern.length < minCharsForSuggestions) {
              return [];
            }
            return await suggestionsCallback(pattern);
          },

          // Item builder
          itemBuilder: itemBuilder,

          // Separator builder (optional)
          itemSeparatorBuilder: itemSeparatorBuilder,

          // On selection
          onSelected: onSelected,

          // Builder customizations
          emptyBuilder: emptyBuilder ?? _defaultEmptyBuilder,
          errorBuilder: errorBuilder ?? _defaultErrorBuilder,
          loadingBuilder: loadingBuilder ?? _defaultLoadingBuilder,

          // Suggestions box decoration
          decorationBuilder: (context, child) {
            return Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration:
                    suggestionsBoxDecoration ??
                    BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                child: child,
              ),
            );
          },

          // Text field builder
          builder: (context, controller, focusNode) {
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: keyboardType,
              enabled: enabled,
              maxLines: maxLines,
              style: AppTextStyles.bodyMedium,
              autovalidateMode: autovalidateMode,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyles.hint,
                prefixIcon: prefixIcon != null
                    ? IconTheme(
                        data: const IconThemeData(
                          color: AppColors.iconDefault,
                          size: 20,
                        ),
                        child: prefixIcon!,
                      )
                    : null,
                suffixIcon: suffixIcon != null
                    ? IconTheme(
                        data: const IconThemeData(
                          color: AppColors.iconDefault,
                          size: 20,
                        ),
                        child: suffixIcon!,
                      )
                    : null,
                filled: true,
                fillColor: AppColors.cardBackground,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: prefixIcon == null ? 16 : 12,
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
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 1.5),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.border.withAlpha(100),
                    width: 1,
                  ),
                ),
              ),
              validator: validator,
            );
          },
        ),
      ],
    );
  }

  // Default builders
  Widget _defaultEmptyBuilder(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        'No suggestions available',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _defaultErrorBuilder(BuildContext context, Object? error) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        'Error loading suggestions',
        style: AppTextStyles.bodyMedium.copyWith(color: Colors.red),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _defaultLoadingBuilder(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
    );
  }
}
