import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../data/convex_trainer_repository.dart';

class CheckinSheet extends ConsumerStatefulWidget {
  const CheckinSheet({super.key, required this.bookingId});
  final String bookingId;

  @override
  ConsumerState<CheckinSheet> createState() => _CheckinSheetState();
}

class _CheckinSheetState extends ConsumerState<CheckinSheet> {
  bool _isLoading = false;

  Future<void> _checkIn() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(trainerRepositoryProvider).checkIn(widget.bookingId);
      if (mounted) {
        AppSnackbar.success(context, 'Member checked in!');
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        AppSnackbar.error(context, 'Check-in failed. Try again.');
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _checkOut() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(trainerRepositoryProvider).checkOut(widget.bookingId);
      if (mounted) {
        AppSnackbar.success(context, 'Member checked out. Session complete!');
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        AppSnackbar.error(context, 'Check-out failed. Try again.');
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.elevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Session Check-In',
            style:
                AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Mark the member as checked in or out of this session.',
            style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 56,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _checkIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.background,
                      ),
                    )
                  : Text(
                      'Check In',
                      style: AppTextStyles.button
                          .copyWith(color: AppColors.background),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 56,
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _isLoading ? null : _checkOut,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textMuted,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Check Out',
                style:
                    AppTextStyles.button.copyWith(color: AppColors.textMuted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
