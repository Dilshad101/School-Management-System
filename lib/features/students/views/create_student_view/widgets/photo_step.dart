import 'dart:io';

import 'package:flutter/material.dart';
import 'package:school_management_system/shared/styles/app_styles.dart';

/// Step 4 of Create Student flow - Photo Upload.
class PhotoStep extends StatelessWidget {
  const PhotoStep({
    super.key,
    required this.formKey,
    required this.studentName,
    required this.photo,
    required this.onPickFromGallery,
    required this.onPickFromCamera,
    required this.onRemovePhoto,
  });

  final GlobalKey<FormState> formKey;
  final String studentName;
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
              "Upload $studentName's photo.",
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
                      if (photo != null) ...[
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _ActionButton(
                              icon: Icons.edit,
                              label: 'Change',
                              onTap: () => _showPhotoOptions(context),
                            ),
                            const SizedBox(width: 16),
                            _ActionButton(
                              icon: Icons.delete_outline,
                              label: 'Remove',
                              onTap: onRemovePhoto,
                              isDestructive: true,
                            ),
                          ],
                        ),
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text('Choose Photo', style: AppTextStyles.heading4),
              const SizedBox(height: 20),
              _PhotoOptionTile(
                icon: Icons.photo_library_outlined,
                label: 'Choose from Gallery',
                onTap: () {
                  Navigator.pop(context);
                  onPickFromGallery();
                },
              ),
              const SizedBox(height: 8),
              _PhotoOptionTile(
                icon: Icons.camera_alt_outlined,
                label: 'Take a Photo',
                onTap: () {
                  Navigator.pop(context);
                  onPickFromCamera();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

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
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
      ),
      trailing: Icon(Icons.chevron_right, color: AppColors.textSecondary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: AppColors.background,
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red : AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
