import 'dart:io';

import 'package:flutter/material.dart';
import 'package:school_management_system/shared/styles/app_styles.dart';

/// Step 3 of Create Employee flow - Photo Upload.
class EmployeePhotoStep extends StatelessWidget {
  const EmployeePhotoStep({
    super.key,
    required this.formKey,
    required this.employeeName,
    required this.photo,
    required this.onPickFromGallery,
    required this.onPickFromCamera,
    required this.onRemovePhoto,
  });

  final GlobalKey<FormState> formKey;
  final String employeeName;
  final File? photo;
  final VoidCallback onPickFromGallery;
  final VoidCallback onPickFromCamera;
  final VoidCallback onRemovePhoto;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Section header
            Text(
              "Upload $employeeName's photo.",
              style: AppTextStyles.heading4.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'jpg, png less than 5MB',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 40),

            // Photo picker
            Center(
              child: FormField<File>(
                initialValue: photo,
                validator: (value) {
                  if (value == null) {
                    return 'Please upload a photo';
                  }
                  return null;
                },
                builder: (FormFieldState<File> state) {
                  // Sync the form field value with the widget value
                  if (state.value != photo) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      state.didChange(photo);
                    });
                  }

                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () => _showPhotoOptions(context),
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: state.hasError
                                  ? Colors.red
                                  : AppColors.border.withAlpha(100),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(10),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                            image: photo != null
                                ? DecorationImage(
                                    image: FileImage(photo!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: photo == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.camera_alt_outlined,
                                      size: 48,
                                      color: AppColors.iconDefault,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Choose file',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                      ),
                      if (state.hasError) ...[
                        const SizedBox(height: 12),
                        Text(
                          state.errorText!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.red,
                          ),
                        ),
                      ],

                      // Remove photo button (shown when photo exists)
                      if (photo != null) ...[
                        const SizedBox(height: 24),
                        _RemovePhotoButton(onTap: onRemovePhoto),
                      ],
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Text(
              'Choose Photo',
              style: AppTextStyles.heading4.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            _PhotoOptionTile(
              icon: Icons.photo_library_outlined,
              label: 'Choose from Gallery',
              onTap: () {
                Navigator.pop(context);
                onPickFromGallery();
              },
            ),
            _PhotoOptionTile(
              icon: Icons.camera_alt_outlined,
              label: 'Take a Photo',
              onTap: () {
                Navigator.pop(context);
                onPickFromCamera();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

/// Photo option tile widget.
class _PhotoOptionTile extends StatelessWidget {
  const _PhotoOptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

/// Remove photo button widget.
class _RemovePhotoButton extends StatelessWidget {
  const _RemovePhotoButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
      label: Text(
        'Remove Photo',
        style: AppTextStyles.bodyMedium.copyWith(color: Colors.red),
      ),
    );
  }
}
