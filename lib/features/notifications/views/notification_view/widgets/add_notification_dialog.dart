import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../shared/styles/app_styles.dart';
import '../../../blocs/notification/notification_cubit.dart';

/// Dialog for adding a new notification.
class AddNotificationDialog extends StatelessWidget {
  const AddNotificationDialog({super.key, required this.cubit});

  final NotificationCubit cubit;

  /// Show the dialog.
  static Future<bool?> show(BuildContext context) {
    final cubit = context.read<NotificationCubit>();
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: AddNotificationDialog(cubit: cubit),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: BlocConsumer<NotificationCubit, NotificationState>(
        listener: (context, state) {
          if (state.submissionStatus == NotificationSubmissionStatus.success) {
            Navigator.of(context).pop(true);
            context.read<NotificationCubit>().resetForm();
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text('Add Notification', style: AppTextStyles.heading3),
                  const SizedBox(height: 4),
                  Text(
                    'Choose the audience and share important announcements instantly.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sent To dropdown
                  _buildLabel('Sent To'),
                  const SizedBox(height: 8),
                  _SentToDropdown(
                    value: state.sentTo,
                    onChanged: (value) {
                      context.read<NotificationCubit>().updateSentTo(value);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Class & Division row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Class'),
                            const SizedBox(height: 8),
                            _FormDropdown<String>(
                              value: state.selectedClass,
                              items: state.classes,
                              hintText: 'select class',
                              onChanged: (value) {
                                context
                                    .read<NotificationCubit>()
                                    .updateSelectedClass(value);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Division'),
                            const SizedBox(height: 8),
                            _FormDropdown<String>(
                              value: state.selectedDivision,
                              items: state.divisions,
                              hintText: 'select Division',
                              onChanged: (value) {
                                context
                                    .read<NotificationCubit>()
                                    .updateSelectedDivision(value);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title field
                  _buildLabel('Title'),
                  const SizedBox(height: 8),
                  _FormTextField(
                    hintText: 'Enter notification title',
                    onChanged: (value) {
                      context.read<NotificationCubit>().updateTitle(value);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Message field
                  _buildLabel('Message'),
                  const SizedBox(height: 8),
                  _FormTextField(
                    hintText: 'Add a short description about fee',
                    maxLines: 4,
                    onChanged: (value) {
                      context.read<NotificationCubit>().updateMessage(value);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Attachment
                  Row(
                    children: [
                      _buildLabel('Attachment'),
                      const SizedBox(width: 8),
                      Text(
                        '(Optional)',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _AttachmentField(
                    attachment: state.attachment,
                    onPickFile: () {
                      context.read<NotificationCubit>().pickAttachment();
                    },
                    onRemoveFile: () {
                      context.read<NotificationCubit>().removeAttachment();
                    },
                  ),
                  const SizedBox(height: 24),

                  // Error message
                  if (state.errorMessage != null) ...[
                    Text(
                      state.errorMessage!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: state.isSubmitting
                              ? null
                              : () {
                                  context.read<NotificationCubit>().resetForm();
                                  Navigator.of(context).pop(false);
                                },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: AppColors.border),
                          ),
                          child: Text(
                            'cancel',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ElevatedButton(
                            onPressed: state.isSubmitting
                                ? null
                                : () {
                                    context
                                        .read<NotificationCubit>()
                                        .submitNotification();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: state.isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text('Sent', style: AppTextStyles.button),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600),
    );
  }
}

/// Dropdown for selecting the 'Sent To' audience.
class _SentToDropdown extends StatelessWidget {
  const _SentToDropdown({required this.value, required this.onChanged});

  final NotificationAudience value;
  final ValueChanged<NotificationAudience?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<NotificationAudience>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.textSecondary,
          ),
          items: NotificationAudience.values
              .map(
                (audience) => DropdownMenuItem<NotificationAudience>(
                  value: audience,
                  child: Text(
                    audience.label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// Generic form dropdown.
class _FormDropdown<T> extends StatelessWidget {
  const _FormDropdown({
    required this.value,
    required this.items,
    required this.hintText,
    required this.onChanged,
  });

  final T? value;
  final List<T> items;
  final String hintText;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: Text(
            hintText,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.textSecondary,
            size: 20,
          ),
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    item.toString(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// Text field for the form.
class _FormTextField extends StatelessWidget {
  const _FormTextField({
    required this.hintText,
    required this.onChanged,
    this.maxLines = 1,
  });

  final String hintText;
  final ValueChanged<String> onChanged;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}

/// Attachment field with file picker.
class _AttachmentField extends StatelessWidget {
  const _AttachmentField({
    required this.attachment,
    required this.onPickFile,
    required this.onRemoveFile,
  });

  final dynamic attachment;
  final VoidCallback onPickFile;
  final VoidCallback onRemoveFile;

  @override
  Widget build(BuildContext context) {
    final hasAttachment = attachment != null;
    final fileName = hasAttachment
        ? (attachment.path as String).split('/').last
        : 'Choose file';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.attach_file, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              fileName,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (hasAttachment)
            GestureDetector(
              onTap: onRemoveFile,
              child: Icon(
                Icons.close,
                color: AppColors.textSecondary,
                size: 18,
              ),
            )
          else
            GestureDetector(
              onTap: onPickFile,
              child: Text(
                'Upload',
                style: AppTextStyles.link.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
        ],
      ),
    );
  }
}
