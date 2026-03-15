import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';

class ChatInput extends StatefulWidget {
  const ChatInput({
    super.key,
    required this.onSend,
    this.enabled = true,
    this.onPickImage,
    this.onTextChanged,
  });

  final void Function(String content) onSend;
  final bool enabled;

  /// Called when the user taps the image/camera icon.
  /// When null, no icon button is shown.
  final VoidCallback? onPickImage;

  /// Called on every text change — used by parent to signal typing state.
  final VoidCallback? onTextChanged;

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  int _charCount = 0;

  static const int _maxChars = 4000;
  static const int _charWarningThreshold = 3800;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() => _charCount = _controller.text.length);
    widget.onTextChanged?.call();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty || !widget.enabled) return;
    if (text.length > _maxChars) return;
    _controller.clear();
    widget.onSend(text);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _charCount > 0;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      padding: EdgeInsets.only(
        left: 12,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Camera / image picker icon — only shown when callback provided.
              if (widget.onPickImage != null) ...[
                IconButton(
                  onPressed: widget.enabled ? widget.onPickImage : null,
                  icon: Icon(
                    Icons.image_outlined,
                    color: widget.enabled
                        ? AppColors.textMuted
                        : AppColors.border,
                  ),
                  tooltip: 'Send image',
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: TextField(
                  controller: _controller,
                  enabled: widget.enabled,
                  maxLines: 4,
                  minLines: 1,
                  maxLength: _maxChars,
                  buildCounter: (
                      _,
                      {required currentLength,
                      required isFocused,
                      maxLength}) =>
                      null,
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.textPrimary),
                  cursorColor: AppColors.primary,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: AppTextStyles.body
                        .copyWith(color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.elevated,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.border, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.border, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 1),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.border, width: 1),
                    ),
                  ),
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: hasText && widget.enabled ? _handleSend : null,
                icon: Icon(
                  Icons.send_rounded,
                  color: hasText && widget.enabled
                      ? AppColors.primary
                      : AppColors.textMuted,
                ),
              ),
            ],
          ),
          if (_charCount > _charWarningThreshold)
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 48),
              child: Text(
                '$_charCount/$_maxChars',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textMuted),
              ),
            ),
        ],
      ),
    );
  }
}
