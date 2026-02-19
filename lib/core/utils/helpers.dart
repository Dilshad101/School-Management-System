import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:school_management_system/shared/widgets/buttons/gradient_button.dart';

import '../../shared/styles/app_styles.dart';

class Helpers {
  /// Shows a warning bottom sheet with confirm and cancel options
  ///
  /// [confirmDelaySeconds] - Optional delay before enabling the confirm button.
  /// If set, shows a countdown timer on the confirm button.
  static showWarningBottomSheet(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'OK',
    String cancelText = 'Cancel',
    void Function()? onConfirm,
    void Function()? onCancel,
    Color? confirmColor,
    IconData icon = Icons.warning_amber_rounded,
    int? confirmDelaySeconds,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _WarningBottomSheetContent(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        confirmColor: confirmColor,
        icon: icon,
        confirmDelaySeconds: confirmDelaySeconds,
      ),
    );
  }
}

/// Stateful widget for the bottom sheet content to handle timer
class _WarningBottomSheetContent extends StatefulWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final void Function()? onConfirm;
  final void Function()? onCancel;
  final Color? confirmColor;
  final IconData icon;
  final int? confirmDelaySeconds;

  const _WarningBottomSheetContent({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.confirmColor,
    required this.icon,
    this.confirmDelaySeconds,
  });

  @override
  State<_WarningBottomSheetContent> createState() =>
      _WarningBottomSheetContentState();
}

class _WarningBottomSheetContentState
    extends State<_WarningBottomSheetContent> {
  late int _remainingSeconds;
  bool _isConfirmEnabled = true;

  @override
  void initState() {
    super.initState();
    if (widget.confirmDelaySeconds != null && widget.confirmDelaySeconds! > 0) {
      _remainingSeconds = widget.confirmDelaySeconds!;
      _isConfirmEnabled = false;
      _startCountdown();
    }
  }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));

      // Check if widget is still mounted before updating state
      if (!mounted) return false;

      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          _isConfirmEnabled = true;
        }
      });

      return _remainingSeconds > 0 && mounted;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.borderError.withAlpha(0x1A),
                shape: BoxShape.circle,
              ),
              child: Icon(widget.icon, color: AppColors.borderError, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              widget.title,
              style: AppTextStyles.heading4.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onSurface.withAlpha(0x99),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onCancel?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(widget.cancelText),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GradientButton(
                    label: _isConfirmEnabled
                        ? widget.confirmText
                        : '${widget.confirmText} ($_remainingSeconds)',
                    onPressed: _isConfirmEnabled
                        ? () {
                            Navigator.pop(context);
                            widget.onConfirm?.call();
                          }
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
