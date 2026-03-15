import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../providers/app_config_provider.dart';

/// Full-screen maintenance mode gate.
///
/// Shows the maintenance message from [AppConfig] and a "Try Again" button
/// that re-fetches config via [appConfigProvider].
class MaintenanceScreen extends ConsumerWidget {
  const MaintenanceScreen({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.construction_rounded,
                    size: 56,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Under Maintenance',
                  style: AppTextStyles.heading1
                      .copyWith(color: AppColors.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  message ??
                      'We are performing scheduled maintenance to improve '
                          'your experience. Please check back shortly.',
                  style:
                      AppTextStyles.body.copyWith(color: AppColors.textMuted),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () => ref.invalidate(appConfigProvider),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(
                          color: AppColors.primary, width: 1.5),
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    child: Text(
                      'Try Again',
                      style: AppTextStyles.button
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
