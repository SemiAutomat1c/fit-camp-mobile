import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import '../../../../../shared/router/app_router.dart';
import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_text_styles.dart';
import '../../../../../shared/widgets/permission_rationale_dialog.dart';
import '../../../../../shared/widgets/primary_button.dart';
import '../../../../push_notifications/services/push_notification_service.dart';
import '../../providers/auth_provider.dart';

/// Post-onboarding welcome screen shown after the member completes profile setup.
///
/// Plays the success Lottie animation, greets the user by name, and transitions
/// to the main app via [AppInitState.ready].
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
    // Haptic celebration on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      HapticFeedback.mediumImpact();
    });
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  Future<void> _letsGo() async {
    HapticFeedback.mediumImpact();
    if (!mounted) return;

    final allowed = await showPermissionRationaleDialog(
      context,
      icon: Icons.notifications_rounded,
      title: 'Stay in the Loop',
      body:
          'Enable notifications to get session reminders and updates from your trainer.',
    );

    if (allowed) {
      await PushNotificationService().requestPermission();
    }

    if (mounted) {
      ref.read(appInitProvider.notifier).state = AppInitState.ready;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(authNotifierProvider);
    final userName = userAsync.valueOrNull?.name ?? 'Athlete';
    final firstName = userName.split(' ').first;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              SizedBox(
                width: 240,
                height: 240,
                child: Lottie.asset(
                  'assets/lottie/lottie_success.json',
                  controller: _lottieController,
                  onLoaded: (composition) {
                    _lottieController
                      ..duration = composition.duration
                      ..forward();
                  },
                  repeat: false,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome to 24 Fit Camp!',
                style: AppTextStyles.heading1
                    .copyWith(color: AppColors.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "You're all set, $firstName. Your fitness journey starts now.",
                style:
                    AppTextStyles.body.copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              PrimaryButton(
                label: "Let's Go!",
                onPressed: _letsGo,
                icon: Icons.arrow_forward_rounded,
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
