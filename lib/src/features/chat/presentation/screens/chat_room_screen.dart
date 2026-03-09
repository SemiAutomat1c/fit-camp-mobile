import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/convex_chat_repository.dart';
import '../../domain/entities/message.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_input.dart';
import '../widgets/day_header.dart';
import '../widgets/message_bubble.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  const ChatRoomScreen({
    super.key,
    required this.conversationId,
    required this.otherName,
    this.otherAvatarUrl,
  });

  final String conversationId;
  final String otherName;
  final String? otherAvatarUrl;

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen>
    with WidgetsBindingObserver {
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startPolling();
    _markRead();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      ref.invalidate(messagesProvider(widget.conversationId));
    });
  }

  Future<void> _markRead() async {
    try {
      final repo = ref.read(chatRepositoryProvider);
      await repo.markRead(widget.conversationId);
    } catch (_) {
      // Best-effort — do not surface mark-read errors to the user.
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pollTimer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      _startPolling();
      ref.invalidate(messagesProvider(widget.conversationId));
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _sendMessage(String content) async {
    final tempId = 'pending_${DateTime.now().millisecondsSinceEpoch}';
    final currentUserId =
        ref.read(authNotifierProvider).valueOrNull?.id ?? '';
    final pending = Message(
      id: tempId,
      conversationId: widget.conversationId,
      senderId: currentUserId,
      content: content,
      createdAt: DateTime.now(),
      isPending: true,
    );

    ref
        .read(pendingMessagesProvider(widget.conversationId).notifier)
        .addPending(pending);

    try {
      final repo = ref.read(chatRepositoryProvider);
      await repo.sendMessage(widget.conversationId, content);
      ref
          .read(pendingMessagesProvider(widget.conversationId).notifier)
          .removePending(tempId);
      ref.invalidate(messagesProvider(widget.conversationId));
    } catch (_) {
      ref
          .read(pendingMessagesProvider(widget.conversationId).notifier)
          .markFailed(tempId);
      if (mounted) {
        AppSnackbar.error(context, 'Failed to send message. Tap to retry.');
      }
    }
  }

  void _retryMessage(Message msg) {
    ref
        .read(pendingMessagesProvider(widget.conversationId).notifier)
        .removePending(msg.id);
    _sendMessage(msg.content);
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesProvider(widget.conversationId));
    final pending = ref.watch(pendingMessagesProvider(widget.conversationId));
    final userId = ref.watch(authNotifierProvider).valueOrNull?.id;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          widget.otherName,
          style: AppTextStyles.heading4.copyWith(color: AppColors.textPrimary),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (err, _) => Center(
                child: Text(
                  'Could not load messages.',
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.textMuted),
                ),
              ),
              data: (serverMessages) {
                final allMessages = [...serverMessages, ...pending];
                if (allMessages.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages yet. Say hello!',
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.textMuted),
                    ),
                  );
                }

                final items = _buildItems(allMessages, userId);

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    if (item is _DayItem) {
                      return DayHeader(date: item.date);
                    }
                    final msgItem = item as _MessageItem;
                    final msg = msgItem.message;
                    final isOwn = msg.isPending || msg.senderId == userId;
                    final bubble = MessageBubble(
                      message: msg,
                      isOwn: isOwn,
                      showTimestamp: msgItem.showTimestamp,
                      senderName: isOwn ? null : widget.otherName,
                      senderAvatarUrl: isOwn ? null : widget.otherAvatarUrl,
                    );
                    if (msg.isFailed) {
                      return GestureDetector(
                        onTap: () => _retryMessage(msg),
                        child: bubble,
                      );
                    }
                    return bubble;
                  },
                );
              },
            ),
          ),
          ChatInput(onSend: _sendMessage),
        ],
      ),
    );
  }

  /// Builds a reversed list of display items (messages + day headers).
  ///
  /// The list is reversed because [ListView] is reversed — index 0 is the
  /// bottom of the screen.
  List<_ListItem> _buildItems(List<Message> messages, String? userId) {
    final sorted = [...messages]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final items = <_ListItem>[];

    for (int i = 0; i < sorted.length; i++) {
      final msg = sorted[i];
      final prev = i > 0 ? sorted[i - 1] : null;

      final msgDay =
          DateTime(msg.createdAt.year, msg.createdAt.month, msg.createdAt.day);
      final prevDay = prev != null
          ? DateTime(prev.createdAt.year, prev.createdAt.month,
              prev.createdAt.day)
          : null;

      if (prevDay == null || msgDay != prevDay) {
        items.add(_DayItem(msgDay));
      }

      final isOwn = msg.isPending || msg.senderId == userId;
      final prevIsOwn =
          prev != null && (prev.isPending || prev.senderId == userId);

      bool showTimestamp;
      if (prev == null || isOwn != prevIsOwn) {
        showTimestamp = true;
      } else {
        final gap = msg.createdAt.difference(prev.createdAt);
        showTimestamp = gap.inMinutes > 5;
      }

      items.add(_MessageItem(msg, showTimestamp: showTimestamp));
    }

    return items.reversed.toList();
  }
}

abstract class _ListItem {}

class _DayItem extends _ListItem {
  _DayItem(this.date);
  final DateTime date;
}

class _MessageItem extends _ListItem {
  _MessageItem(this.message, {required this.showTimestamp});
  final Message message;
  final bool showTimestamp;
}
