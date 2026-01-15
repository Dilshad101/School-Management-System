import 'package:flutter/material.dart';
import '../../../shared/styles/app_styles.dart';

class CustomPassField extends StatefulWidget {
  const CustomPassField({
    super.key,
    required this.controller,
    required this.obscureText,
  });
  final TextEditingController controller;
  final bool obscureText;

  @override
  State<CustomPassField> createState() => _CustomPassFieldState();
}

class _CustomPassFieldState extends State<CustomPassField> {
  late bool _obscurePassword;

  @override
  void initState() {
    super.initState();
    _obscurePassword = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Password', style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),

        // Password Field
        TextFormField(
          controller: widget.controller,
          obscureText: _obscurePassword,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Enter your password',
            hintStyle: AppTextStyles.hint,
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: AppColors.iconDefault,
              size: 20,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.iconDefault,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            filled: true,
            fillColor: AppColors.cardBackground,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.borderFocused,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.borderError,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.borderError,
                width: 1.5,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Password is required';
            }
            if (value.length < 6) {
              return 'Minimum 6 characters';
            }
            return null;
          },
        ),
      ],
    );
  }
}
