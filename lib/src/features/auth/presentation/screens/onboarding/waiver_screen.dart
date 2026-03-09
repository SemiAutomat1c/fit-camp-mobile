import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_text_styles.dart';
import '../../../../../shared/widgets/primary_button.dart';
import '../../providers/onboarding_provider.dart';
import 'goal_selection_screen.dart';

class WaiverScreen extends ConsumerStatefulWidget {
  const WaiverScreen({super.key});

  @override
  ConsumerState<WaiverScreen> createState() => _WaiverScreenState();
}

class _WaiverScreenState extends ConsumerState<WaiverScreen> {
  final _scrollController = ScrollController();
  bool _scrolledToBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.atEdge &&
        _scrollController.position.pixels > 0) {
      if (!_scrolledToBottom) {
        setState(() => _scrolledToBottom = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const OnboardingStepIndicator(
                  currentStep: 2, totalSteps: 4),
              const SizedBox(height: 32),
              Text(
                'Liability Waiver',
                style: AppTextStyles.heading2
                    .copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Please read the full waiver before accepting.',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius:
                        const BorderRadius.all(Radius.circular(12)),
                    border:
                        Border.all(color: AppColors.border, width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.all(Radius.circular(12)),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _kWaiverText,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textMuted),
                      ),
                    ),
                  ),
                ),
              ),
              if (!_scrolledToBottom) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.arrow_downward_rounded,
                      size: 14,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Scroll to read the full waiver',
                      style: AppTextStyles.label
                          .copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
              CheckboxListTile(
                value: state.waiverAccepted,
                onChanged: _scrolledToBottom
                    ? (val) {
                        if (val == true) {
                          HapticFeedback.lightImpact();
                        }
                        notifier.setWaiverAccepted(val ?? false);
                      }
                    : null,
                activeColor: AppColors.primary,
                checkColor: AppColors.background,
                title: Text(
                  'I have read and agree to the liability waiver.',
                  style: AppTextStyles.caption.copyWith(
                    color: _scrolledToBottom
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                  ),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 0),
              ),
              const SizedBox(height: 8),
              PrimaryButton(
                label: 'Next',
                onPressed: state.waiverAccepted
                    ? () => context.push('/onboarding/assessment')
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const String _kWaiverText = '''
RELEASE OF LIABILITY, WAIVER OF CLAIMS, AND ASSUMPTION OF RISK AGREEMENT

In consideration of being permitted to participate in any way in the fitness training program offered by 24 Fit Camp ("Gym"), I, the undersigned participant, acknowledge, appreciate, and agree that:

1. ASSUMPTION OF RISK
I understand that fitness activities, including but not limited to weight training, cardiovascular exercises, group fitness classes, and personal training sessions, involve inherent risks. These risks include, but are not limited to, physical injury, muscle strain, joint injury, cardiovascular events, and in extreme cases, permanent disability or death.

2. RELEASE OF LIABILITY
I hereby release, waive, discharge, and covenant not to sue 24 Fit Camp, its owners, officers, employees, agents, instructors, and volunteers (collectively "Releasees") from any and all liability, claims, demands, actions, or causes of action arising from or related to any loss, damage, or injury that may be sustained by me or to any property belonging to me, whether caused by the negligence of the Releasees or otherwise, while participating in such activities.

3. MEDICAL CLEARANCE
I represent that I am physically fit and have no known medical conditions that would prevent my safe participation in fitness activities. I acknowledge that 24 Fit Camp recommends that participants obtain a physician's clearance prior to beginning any fitness program.

4. PERSONAL RESPONSIBILITY
I understand that I am responsible for determining whether the activities are appropriate for my fitness level and physical condition. I agree to inform my trainer or instructor of any physical limitations, injuries, or medical conditions before each session.

5. EQUIPMENT AND FACILITIES
I agree to use all equipment and facilities in a safe and appropriate manner, following all posted rules and the guidance of Gym staff. I accept responsibility for any damage to equipment caused by my improper use.

6. INDEMNIFICATION
I agree to indemnify and hold harmless the Releasees from any loss, liability, damage, or costs, including court costs and legal fees, that may incur due to my participation in fitness activities at 24 Fit Camp.

7. SEVERABILITY
I expressly agree that this release is intended to be as broad and inclusive as permitted by applicable law. If any portion of this agreement is held to be invalid or unenforceable, the balance of the agreement shall continue in full legal force and effect.

8. ACKNOWLEDGMENT
I have read this release of liability and fully understand its terms. I understand that I am giving up substantial rights by signing it, and I sign it freely and voluntarily without any inducement.

By checking the acceptance box below, I indicate that I have read, understood, and agreed to all terms and conditions of this liability waiver.
''';
