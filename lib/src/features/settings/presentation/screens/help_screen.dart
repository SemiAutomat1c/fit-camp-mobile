import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_snackbar.dart';

class HelpScreen extends ConsumerWidget {
  const HelpScreen({super.key});

  static const List<_FaqItem> _faqs = [
    _FaqItem(
      question: 'How do I book a session?',
      answer:
          'Go to the Bookings tab and tap "Book a Session". Select an available '
          'date and time slot, add any notes for your trainer, then confirm your booking.',
    ),
    _FaqItem(
      question: 'Can I cancel my booking?',
      answer:
          'Yes. Open the Bookings tab and swipe left on any pending booking, '
          'or long-press a booking card and select "Cancel Booking". '
          'Only bookings in Pending status can be cancelled.',
    ),
    _FaqItem(
      question: 'How do I track my progress?',
      answer:
          'Navigate to the Progress tab and tap "Log Progress". Enter your '
          'current weight, optional notes, and optionally attach a progress photo. '
          'Your stats and charts will update automatically.',
    ),
    _FaqItem(
      question: 'How do I contact my trainer?',
      answer:
          'Open the Chat tab to see your conversation with your assigned trainer. '
          'Tap the conversation to send messages, share files, or ask questions '
          'in real time.',
    ),
    _FaqItem(
      question: 'How do I update my profile?',
      answer:
          'Tap the person icon in the top-right corner of the Home screen, then '
          'select "Edit Profile". You can update your name, phone number, avatar, '
          'height, weight, and other personal details.',
    ),
    _FaqItem(
      question: 'What if I forget my password?',
      answer:
          'On the login screen, tap "Forgot Password?" and enter your registered '
          'email address. You will receive a password-reset link. Follow the link '
          'to set a new password and sign back in.',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Help & Support',
          style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(
            'Frequently Asked Questions',
            style: AppTextStyles.bodyMed.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          ...(_faqs.map((faq) => _FaqTile(item: faq))),
          const SizedBox(height: 32),
          const _ContactSupportButton(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// FAQ data model
// ---------------------------------------------------------------------------

class _FaqItem {
  const _FaqItem({required this.question, required this.answer});

  final String question;
  final String answer;
}

// ---------------------------------------------------------------------------
// FAQ tile (expansion)
// ---------------------------------------------------------------------------

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.item});

  final _FaqItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding:
              const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          iconColor: AppColors.primary,
          collapsedIconColor: AppColors.textMuted,
          title: Text(
            item.question,
            style: AppTextStyles.bodyMed
                .copyWith(color: AppColors.textPrimary),
          ),
          children: [
            Text(
              item.answer,
              style:
                  AppTextStyles.body.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Contact support button
// ---------------------------------------------------------------------------

class _ContactSupportButton extends StatelessWidget {
  const _ContactSupportButton();

  static const String _supportEmail = 'support@24fitcamp.com';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () => _launchEmail(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        icon: const Icon(Icons.mail_outline_rounded, size: 20),
        label: Text(
          'Contact Support',
          style: AppTextStyles.button.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }

  Future<void> _launchEmail(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      query: 'subject=24 Fit Camp Support Request',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        AppSnackbar.error(
            context, 'Could not open email app. Contact $_supportEmail directly.');
      }
    }
  }
}
