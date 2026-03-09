import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import 'chat_list_screen.dart';
import 'chat_room_screen.dart';

class ChatTabScreen extends ConsumerWidget {
  const ChatTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authNotifierProvider);

    return authAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (_, __) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text(
            'Authentication error.',
            style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
          ),
        ),
      ),
      data: (user) {
        if (user == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Text(
                'Not authenticated.',
                style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
              ),
            ),
          );
        }

        if (user.isTrainer) {
          return const ChatListScreen();
        }

        return const _MemberChatView();
      },
    );
  }
}

/// Member view — auto-creates or loads the existing conversation then shows
/// the chat room inline (no navigation required).
class _MemberChatView extends ConsumerWidget {
  const _MemberChatView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationAsync = ref.watch(memberConversationNotifierProvider);

    return conversationAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (err, _) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text(
            'Could not load conversation.',
            style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
          ),
        ),
      ),
      data: (conversation) {
        if (conversation != null) {
          return ChatRoomScreen(
            conversationId: conversation.id,
            otherName: conversation.otherParticipantName ?? 'Trainer',
            otherAvatarUrl: conversation.otherParticipantAvatarUrl,
          );
        }

        // No conversation yet — auto-create.
        return _CreateConversationView(
          onCreated: () => ref.invalidate(memberConversationNotifierProvider),
        );
      },
    );
  }
}

class _CreateConversationView extends ConsumerStatefulWidget {
  const _CreateConversationView({required this.onCreated});

  final VoidCallback onCreated;

  @override
  ConsumerState<_CreateConversationView> createState() =>
      _CreateConversationViewState();
}

class _CreateConversationViewState
    extends ConsumerState<_CreateConversationView> {
  bool _loading = false;

  Future<void> _start() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      await ref
          .read(memberConversationNotifierProvider.notifier)
          .ensureConversation();
      if (mounted) {
        widget.onCreated();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not start conversation. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Auto-start without requiring a button tap.
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: _loading
            ? const CircularProgressIndicator(color: AppColors.primary)
            : Text(
                'Starting chat...',
                style:
                    AppTextStyles.body.copyWith(color: AppColors.textMuted),
              ),
      ),
    );
  }
}

