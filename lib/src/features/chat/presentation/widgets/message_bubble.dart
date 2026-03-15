import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../domain/entities/message.dart';

class MessageBubble extends StatefulWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isOwn,
    required this.alwaysShowTimestamp,
    this.senderName,
    this.senderAvatarUrl,
  });

  final Message message;
  final bool isOwn;

  /// When true the timestamp is always visible (e.g. first message in a group).
  /// A per-tap toggle is layered on top of this.
  final bool alwaysShowTimestamp;
  final String? senderName;
  final String? senderAvatarUrl;

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool _showTimestamp = false;

  void _toggleTimestamp() {
    setState(() => _showTimestamp = !_showTimestamp);
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    final isOwn = widget.isOwn;
    final maxWidth = MediaQuery.of(context).size.width * 0.75;
    final isPending = message.isPending;
    final isFailed = message.isFailed;
    final hasImage = message.imageUrl != null;

    final bgColor = isOwn ? AppColors.primary : const Color(0xFF1E1E1E);
    final textColor = isOwn ? AppColors.background : AppColors.textPrimary;
    final opacity = (isPending || isFailed) ? 0.7 : 1.0;

    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(12),
      topRight: const Radius.circular(12),
      bottomLeft: isOwn ? const Radius.circular(12) : const Radius.circular(4),
      bottomRight:
          isOwn ? const Radius.circular(4) : const Radius.circular(12),
    );

    // -----------------------------------------------------------------------
    // Bubble content
    // -----------------------------------------------------------------------

    Widget bubbleContent;

    if (hasImage) {
      // Image message — may also have a text caption below the image.
      final heroTag = 'msg_${message.id}';
      final imageWidget = Hero(
        tag: heroTag,
        child: ClipRRect(
          borderRadius: borderRadius,
          child: CachedNetworkImage(
            imageUrl: message.imageUrl!,
            width: 200,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: 200,
              height: 160,
              color: AppColors.elevated,
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              width: 200,
              height: 120,
              color: AppColors.elevated,
              child: const Icon(
                Icons.broken_image,
                color: AppColors.textMuted,
                size: 40,
              ),
            ),
          ),
        ),
      );

      bubbleContent = GestureDetector(
        onTap: () {
          context.push(
            '/progress/photo/msg_${message.id}',
            extra: {'imageUrl': message.imageUrl!},
          );
        },
        child: Opacity(
          opacity: opacity,
          child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                imageWidget,
                if (message.content.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.only(
                        bottomLeft: isOwn
                            ? const Radius.circular(12)
                            : const Radius.circular(4),
                        bottomRight: isOwn
                            ? const Radius.circular(4)
                            : const Radius.circular(12),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    child: Text(
                      message.content,
                      style: AppTextStyles.body.copyWith(color: textColor),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    } else {
      // Text-only message.
      bubbleContent = GestureDetector(
        onTap: _toggleTimestamp,
        child: Opacity(
          opacity: opacity,
          child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: borderRadius,
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              message.content,
              style: AppTextStyles.body.copyWith(color: textColor),
            ),
          ),
        ),
      );
    }

    // -----------------------------------------------------------------------
    // Read receipt icon (own messages only)
    // -----------------------------------------------------------------------

    Widget? receiptIcon;
    if (isOwn && !isPending && !isFailed) {
      receiptIcon = Icon(
        message.readAt != null
            ? Icons.done_all_rounded
            : Icons.check_rounded,
        size: 14,
        color: message.readAt != null
            ? AppColors.primary
            : AppColors.textMuted,
      );
    }

    // -----------------------------------------------------------------------
    // Timestamp visibility — always shown when alwaysShowTimestamp=true,
    // or when tapped by the user.
    // -----------------------------------------------------------------------

    final timestampVisible =
        (widget.alwaysShowTimestamp || _showTimestamp) && !isPending && !isFailed;

    return Align(
      alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: hasImage ? null : _toggleTimestamp,
        behavior: HitTestBehavior.translucent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Column(
            crossAxisAlignment:
                isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!isOwn) ...[
                    AppAvatar(
                      name: widget.senderName ?? 'Trainer',
                      imageUrl: widget.senderAvatarUrl,
                      size: AppAvatarSize.sm,
                    ),
                    const SizedBox(width: 6),
                  ],
                  bubbleContent,
                  if (receiptIcon != null) ...[
                    const SizedBox(width: 4),
                    receiptIcon,
                  ],
                ],
              ),
              if (isPending)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    'Sending...',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textMuted),
                  ),
                ),
              if (isFailed)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 14, color: AppColors.error),
                      const SizedBox(width: 4),
                      Text(
                        'Tap to retry',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.error),
                      ),
                    ],
                  ),
                ),
              AnimatedSize(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                child: timestampVisible
                    ? Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          _formatTime(message.createdAt),
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.textMuted),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = h < 12 ? 'AM' : 'PM';
    final displayH = h == 0 ? 12 : h > 12 ? h - 12 : h;
    return '$displayH:$m $period';
  }
}
