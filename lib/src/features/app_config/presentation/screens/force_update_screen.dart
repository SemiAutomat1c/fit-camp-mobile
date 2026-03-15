import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';

/// Full-screen gate shown when the installed app version is below the minimum
/// required version. Back navigation is suppressed — users must update.
class ForceUpdateScreen extends ConsumerWidget {
  const ForceUpdateScreen({super.key});

  static const String _iosUrl =
      'https://apps.apple.com/app/id000000000';
  static const String _androidUrl =
      'https://play.google.com/store/apps/details?id=com.fitcamp.mobile';

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
                // App icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.fitness_center_rounded,
                    size: 56,
                    color: AppColors.background,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Update Required',
                  style: AppTextStyles.heading1
                      .copyWith(color: AppColors.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'A new version of 24 Fit Camp is available. Please update '
                  'to continue using the app and access the latest features.',
                  style:
                      AppTextStyles.body.copyWith(color: AppColors.textMuted),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _openStore,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.background,
                      elevation: 0,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    child: Text(
                      'Update Now',
                      style: AppTextStyles.button
                          .copyWith(color: AppColors.background),
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

  Future<void> _openStore() async {
    final storeUrl = Platform.isIOS ? _iosUrl : _androidUrl;
    final uri = Uri.parse(storeUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
