import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../domain/entities/message.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isOwn,
    required this.showTimestamp,
    this.senderName,
    this.senderAvatarUrl,
  });

  final Message message;
  final bool isOwn;
  final bool showTimestamp;
  final String? senderName;
  final String? senderAvatarUrl;

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.75;
    final isPending = message.isPending;
    final isFailed = message.isFailed;

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

    final bubble = Opacity(
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
    );

    return Align(
      alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
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
                // Sender avatar on the left for received messages
                if (!isOwn) ...[
                  AppAvatar(
                    name: senderName ?? 'Trainer',
                    imageUrl: senderAvatarUrl,
                    size: AppAvatarSize.sm,
                  ),
                  const SizedBox(width: 6),
                ],
                bubble,
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
            if (showTimestamp && !isPending && !isFailed)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  _formatTime(message.createdAt),
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textMuted),
                ),
              ),
          ],
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
