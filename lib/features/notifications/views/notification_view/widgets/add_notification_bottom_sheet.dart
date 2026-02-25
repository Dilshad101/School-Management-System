import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';

import '../../../../../shared/styles/app_styles.dart';
import '../../../../students/models/class_room_model.dart';
import '../../../../students/models/student_model.dart';
import '../../../blocs/notification/notification_cubit.dart';

/// Bottom sheet for adding a new notification.
class AddNotificationBottomSheet extends StatefulWidget {
  const AddNotificationBottomSheet({super.key, required this.cubit});

  final NotificationCubit cubit;

  /// Show the bottom sheet.
  static Future<bool?> show(BuildContext context) {
    final cubit = context.read<NotificationCubit>();
    return showModalBottomSheet<bool>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => BlocProvider.value(
        value: cubit,
        child: AddNotificationBottomSheet(cubit: cubit),
      ),
    );
  }

  @override
  State<AddNotificationBottomSheet> createState() =>
      _AddNotificationBottomSheetState();
}

class _AddNotificationBottomSheetState
    extends State<AddNotificationBottomSheet> {
  final _classController = TextEditingController();
  final _studentController = TextEditingController();

  @override
  void dispose() {
    _classController.dispose();
    _studentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollController) {
        return BlocConsumer<NotificationCubit, NotificationState>(
          listenWhen: (previous, current) =>
              previous.submissionStatus != current.submissionStatus,
          listener: (listenerContext, state) {
            if (state.submissionStatus ==
                NotificationSubmissionStatus.success) {
              // Use rootNavigator: false to only pop the bottom sheet, not the underlying route
              Navigator.of(listenerContext, rootNavigator: false).pop(true);
              listenerContext.read<NotificationCubit>().resetForm();
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Add Notification', style: AppTextStyles.heading3),
                    const SizedBox(height: 4),
                    Text(
                      'Choose the audience and share important announcements instantly.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildLabel('Sent To', isRequired: true),
                    const SizedBox(height: 8),
                    _SentToDropdown(
                      value: state.sentTo,
                      onChanged: (value) {
                        context.read<NotificationCubit>().updateSentTo(value);
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Class'),
                    const SizedBox(height: 8),
                    _ClassSuggestionField(
                      controller: _classController,
                      selectedClasses: state.selectedClasses,
                      onSearch: (query) => context
                          .read<NotificationCubit>()
                          .searchClassrooms(query),
                      onSelected: (classroom) {
                        context.read<NotificationCubit>().addClass(classroom);
                        _classController.clear();
                      },
                      onRemove: (classroom) {
                        context.read<NotificationCubit>().removeClass(
                          classroom,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Student'),
                    const SizedBox(height: 8),
                    _StudentSuggestionField(
                      controller: _studentController,
                      selectedStudents: state.selectedStudents,
                      onSearch: (query) => context
                          .read<NotificationCubit>()
                          .searchStudents(query),
                      onSelected: (student) {
                        context.read<NotificationCubit>().addStudent(student);
                        _studentController.clear();
                      },
                      onRemove: (student) {
                        context.read<NotificationCubit>().removeStudent(
                          student,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Title', isRequired: true),
                    const SizedBox(height: 8),
                    _FormTextField(
                      hintText: 'Enter notification title',
                      onChanged: (value) {
                        context.read<NotificationCubit>().updateTitle(value);
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildLabel('Message', isRequired: true),
                    const SizedBox(height: 8),
                    _FormTextField(
                      hintText: 'Add a short description',
                      maxLines: 4,
                      onChanged: (value) {
                        context.read<NotificationCubit>().updateMessage(value);
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildLabel('Schedule Date & Time'),
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
                    _DateTimePickerField(
                      selectedDateTime: state.scheduledDateTime,
                      onDateTimeSelected: (dateTime) {
                        context
                            .read<NotificationCubit>()
                            .updateScheduledDateTime(dateTime);
                      },
                      onClear: () {
                        context
                            .read<NotificationCubit>()
                            .updateScheduledDateTime(null);
                      },
                    ),
                    const SizedBox(height: 16),
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
                    if (state.errorMessage != null) ...[
                      Text(
                        state.errorMessage!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: state.isSubmitting
                                ? null
                                : () {
                                    context
                                        .read<NotificationCubit>()
                                        .resetForm();
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
                              'Cancel',
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
                                  : Text('Send', style: AppTextStyles.button),
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
        );
      },
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Text.rich(
      TextSpan(
        text: text,
        style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600),
        children: [
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }
}

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

class _ClassSuggestionField extends StatelessWidget {
  const _ClassSuggestionField({
    required this.controller,
    required this.selectedClasses,
    required this.onSearch,
    required this.onSelected,
    required this.onRemove,
  });
  final TextEditingController controller;
  final List<ClassRoomModel> selectedClasses;
  final Future<List<ClassRoomModel>> Function(String) onSearch;
  final ValueChanged<ClassRoomModel> onSelected;
  final ValueChanged<ClassRoomModel> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedClasses.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedClasses.map((classroom) {
              return Chip(
                label: Text(classroom.name, style: AppTextStyles.bodySmall),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => onRemove(classroom),
                backgroundColor: AppColors.primary.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
        TypeAheadField<ClassRoomModel>(
          controller: controller,
          hideOnEmpty: true,
          debounceDuration: const Duration(milliseconds: 300),
          suggestionsCallback: (pattern) async {
            if (pattern.isEmpty) return [];
            final results = await onSearch(pattern);
            return results
                .where((c) => !selectedClasses.any((s) => s.id == c.id))
                .toList();
          },
          itemBuilder: (context, classroom) {
            return ListTile(
              dense: true,
              title: Text(classroom.name, style: AppTextStyles.bodyMedium),
              subtitle: classroom.academicYearDetails != null
                  ? Text(
                      classroom.academicYearDetails!.name,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    )
                  : null,
            );
          },
          onSelected: onSelected,
          emptyBuilder: (context) => const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No classes found'),
          ),
          decorationBuilder: (context, child) {
            return Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: child,
              ),
            );
          },
          builder: (context, controller, focusNode) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: 'Search class...',
                hintStyle: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                  size: 20,
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
          },
        ),
      ],
    );
  }
}

class _StudentSuggestionField extends StatelessWidget {
  const _StudentSuggestionField({
    required this.controller,
    required this.selectedStudents,
    required this.onSearch,
    required this.onSelected,
    required this.onRemove,
  });
  final TextEditingController controller;
  final List<StudentModel> selectedStudents;
  final Future<List<StudentModel>> Function(String) onSearch;
  final ValueChanged<StudentModel> onSelected;
  final ValueChanged<StudentModel> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedStudents.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedStudents.map((student) {
              return Chip(
                label: Text(student.fullName, style: AppTextStyles.bodySmall),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => onRemove(student),
                backgroundColor: AppColors.primary.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
        TypeAheadField<StudentModel>(
          controller: controller,
          hideOnEmpty: true,
          debounceDuration: const Duration(milliseconds: 300),
          suggestionsCallback: (pattern) async {
            if (pattern.isEmpty) return [];
            final results = await onSearch(pattern);
            return results
                .where((s) => !selectedStudents.any((sel) => sel.id == s.id))
                .toList();
          },
          itemBuilder: (context, student) {
            return ListTile(
              dense: true,
              title: Text(student.fullName, style: AppTextStyles.bodyMedium),
              subtitle: Text(
                student.email,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            );
          },
          onSelected: onSelected,
          emptyBuilder: (context) => const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No students found'),
          ),
          decorationBuilder: (context, child) {
            return Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: child,
              ),
            );
          },
          builder: (context, controller, focusNode) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: 'Search student...',
                hintStyle: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                  size: 20,
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
          },
        ),
      ],
    );
  }
}

class _FormTextField extends StatelessWidget {
  const _FormTextField({
    this.hintText,
    this.maxLines = 1,
    required this.onChanged,
  });
  final String? hintText;
  final int maxLines;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLines: maxLines,
      onChanged: onChanged,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}

class _DateTimePickerField extends StatelessWidget {
  const _DateTimePickerField({
    required this.selectedDateTime,
    required this.onDateTimeSelected,
    required this.onClear,
  });
  final DateTime? selectedDateTime;
  final ValueChanged<DateTime> onDateTimeSelected;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDateTime ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null && context.mounted) {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(
              selectedDateTime ?? DateTime.now(),
            ),
          );
          if (time != null) {
            onDateTimeSelected(
              DateTime(date.year, date.month, date.day, time.hour, time.minute),
            );
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              color: AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedDateTime != null
                    ? DateFormat(
                        'MMM dd, yyyy - hh:mm a',
                      ).format(selectedDateTime!)
                    : 'Select date and time',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: selectedDateTime != null
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
            if (selectedDateTime != null)
              GestureDetector(
                onTap: onClear,
                child: const Icon(
                  Icons.close,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentField extends StatelessWidget {
  const _AttachmentField({
    required this.attachment,
    required this.onPickFile,
    required this.onRemoveFile,
  });
  final File? attachment;
  final VoidCallback onPickFile;
  final VoidCallback onRemoveFile;

  @override
  Widget build(BuildContext context) {
    if (attachment != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.attach_file, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                attachment!.path.split('/').last,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: onRemoveFile,
              child: Icon(Icons.close, color: Colors.red, size: 20),
            ),
          ],
        ),
      );
    }
    return GestureDetector(
      onTap: onPickFile,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.upload_file,
              color: AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Upload Attachment',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
