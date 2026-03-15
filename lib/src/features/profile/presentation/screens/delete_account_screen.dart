import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/convex_profile_repository.dart';

class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final _confirmController = TextEditingController();
  bool _isDeleting = false;
  bool _showConfirmStep = false;

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  bool get _canDelete =>
      _confirmController.text.trim().toUpperCase() == 'DELETE';

  Future<void> _deleteAccount() async {
    if (!_canDelete || _isDeleting) return;
    HapticFeedback.heavyImpact();
    setState(() => _isDeleting = true);
    try {
      final repo = ref.read(profileRepositoryProvider);
      await repo.deleteAccount();
      await ref.read(authNotifierProvider.notifier).signOut();
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(
            context, 'Failed to delete account. Please try again.');
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Delete Account'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _showConfirmStep
            ? _ConfirmStep(
                controller: _confirmController,
                canDelete: _canDelete,
                isDeleting: _isDeleting,
                onChanged: () => setState(() {}),
                onDelete: _deleteAccount,
                onBack: () => setState(() => _showConfirmStep = false),
              )
            : _InfoStep(
                onContinue: () => setState(() => _showConfirmStep = true),
              ),
      ),
    );
  }
}

class _InfoStep extends StatelessWidget {
  const _InfoStep({required this.onContinue});
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.error.withAlpha(26),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.error.withAlpha(77)),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.error,
              size: 44,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Delete Your Account?',
          style: AppTextStyles.heading2.copyWith(color: AppColors.error),
        ),
        const SizedBox(height: 16),
        Text(
          'This action is permanent and cannot be undone. Deleting your account will:',
          style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 16),
        ...[
          'Remove all your personal data and profile information',
          'Cancel any active bookings and sessions',
          'Delete your chat history and messages',
          'Remove all your progress logs and photos',
          'Terminate your gym membership',
        ].map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.close_rounded,
                      color: AppColors.error, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style:
                          AppTextStyles.body.copyWith(color: AppColors.textMuted),
                    ),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 32),
        SizedBox(
          height: 56,
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onContinue,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: BorderSide(color: AppColors.error.withAlpha(120)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'I Understand, Continue',
              style: AppTextStyles.button.copyWith(color: AppColors.error),
            ),
          ),
        ),
      ],
    );
  }
}

class _ConfirmStep extends StatelessWidget {
  const _ConfirmStep({
    required this.controller,
    required this.canDelete,
    required this.isDeleting,
    required this.onChanged,
    required this.onDelete,
    required this.onBack,
  });
  final TextEditingController controller;
  final bool canDelete;
  final bool isDeleting;
  final VoidCallback onChanged;
  final VoidCallback onDelete;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confirm Deletion',
          style:
              AppTextStyles.heading2.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        Text(
          'Type DELETE in the field below to confirm you want to permanently delete your account.',
          style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: controller,
          textCapitalization: TextCapitalization.characters,
          onChanged: (_) => onChanged(),
          style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            labelText: 'Type DELETE to confirm',
            filled: true,
            fillColor: AppColors.surface,
            labelStyle:
                AppTextStyles.body.copyWith(color: AppColors.textMuted),
            floatingLabelStyle: AppTextStyles.caption
                .copyWith(color: AppColors.primary),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 18),
            constraints: const BoxConstraints(minHeight: 56),
            border: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              borderSide:
                  BorderSide(color: AppColors.border, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              borderSide:
                  BorderSide(color: AppColors.border, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              borderSide:
                  BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 24),
        AnimatedOpacity(
          opacity: canDelete ? 1.0 : 0.38,
          duration: const Duration(milliseconds: 200),
          child: SizedBox(
            height: 56,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canDelete && !isDeleting ? onDelete : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.error,
                disabledForegroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: isDeleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text('Delete My Account',
                      style:
                          AppTextStyles.button.copyWith(color: Colors.white)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: onBack,
          child: Text('Go Back',
              style:
                  AppTextStyles.button.copyWith(color: AppColors.textMuted)),
        ),
      ],
    );
  }
}
