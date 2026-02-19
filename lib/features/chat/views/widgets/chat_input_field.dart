import 'package:flutter/material.dart';

import '../../../../shared/styles/app_styles.dart';

/// Input field for composing chat messages.
class ChatInputField extends StatefulWidget {
  const ChatInputField({
    super.key,
    required this.onSend,
    this.isSending = false,
  });

  final Function(String message) onSend;
  final bool isSending;

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _handleSend() {
    final message = _controller.text.trim();
    if (message.isEmpty || widget.isSending) return;

    widget.onSend(message);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            gradient: _hasText ? AppColors.primaryGradient : null,
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(2),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 4,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: AppTextStyles.bodyMedium,
                    onSubmitted: (_) => _handleSend(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: _hasText && !widget.isSending ? _handleSend : null,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: _hasText ? AppColors.primaryGradient : null,
                        color: _hasText ? null : AppColors.border,
                      ),
                      child: widget.isSending
                          ? const Padding(
                              padding: EdgeInsets.all(10),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.send_rounded,
                              color: _hasText
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              size: 20,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
