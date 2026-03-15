import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_text_styles.dart';
import '../../../../../shared/widgets/app_snackbar.dart';
import '../../../../../shared/widgets/app_text_field.dart';
import '../../../../../shared/widgets/primary_button.dart';
import '../../../../../core/services/convex_provider.dart';
import '../../providers/onboarding_provider.dart';
import 'goal_selection_screen.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() =>
      _ProfileSetupScreenState();
}

class _ProfileSetupScreenState
    extends ConsumerState<ProfileSetupScreen> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();

  final _heightFocus = FocusNode();
  final _weightFocus = FocusNode();
  final _ageFocus = FocusNode();

  String? _selectedGender;

  static const List<String> _genders = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say',
  ];

  @override
  void initState() {
    super.initState();
    _heightController.addListener(_rebuild);
    _weightController.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _heightController.removeListener(_rebuild);
    _weightController.removeListener(_rebuild);

    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();

    _heightFocus.dispose();
    _weightFocus.dispose();
    _ageFocus.dispose();
    super.dispose();
  }

  double? get _bmi {
    final h = double.tryParse(_heightController.text);
    final w = double.tryParse(_weightController.text);
    if (h == null || w == null || h <= 0 || w <= 0) return null;
    final hm = h / 100;
    return w / (hm * hm);
  }

  Future<void> _submit() async {
    final notifier = ref.read(onboardingNotifierProvider.notifier);

    notifier.setProfile(
      heightCm: _heightController.text.trim(),
      weightKg: _weightController.text.trim(),
      age: _ageController.text.trim(),
      gender: _selectedGender,
    );

    final userId =
        await ref.read(storageServiceProvider).getUserId() ?? '';

    if (userId.isEmpty) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Session expired. Please sign in again.');
      return;
    }

    final success = await notifier.submit(userId);

    if (!mounted) return;

    if (success) {
      HapticFeedback.mediumImpact();
      context.go('/onboarding/welcome');
    } else {
      final error = ref.read(onboardingNotifierProvider).error;
      AppSnackbar.error(
          context, error ?? 'Setup failed. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingNotifierProvider);
    final bmi = _bmi;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const OnboardingStepIndicator(
                  currentStep: 4, totalSteps: 4),
              const SizedBox(height: 32),
              Text(
                'Profile Setup',
                style: AppTextStyles.heading2
                    .copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Optional — helps us tailor your training.',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Height (cm)',
                      hint: '175',
                      controller: _heightController,
                      focusNode: _heightFocus,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          _weightFocus.requestFocus(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: 'Weight (kg)',
                      hint: '70',
                      controller: _weightController,
                      focusNode: _weightFocus,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _ageFocus.requestFocus(),
                    ),
                  ),
                ],
              ),
              if (bmi != null) ...[
                const SizedBox(height: 12),
                _BmiBadge(bmi: bmi),
              ],
              const SizedBox(height: 12),
              AppTextField(
                label: 'Age',
                hint: '28',
                controller: _ageController,
                focusNode: _ageFocus,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 24),
              Text(
                'Gender',
                style: AppTextStyles.heading4
                    .copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _genders.map((gender) {
                  final selected = _selectedGender == gender;
                  return FilterChip(
                    label: Text(gender),
                    selected: selected,
                    onSelected: (_) => setState(
                        () => _selectedGender =
                            selected ? null : gender),
                    selectedColor: AppColors.primary.withAlpha(30),
                    checkmarkColor: AppColors.primary,
                    side: BorderSide(
                      color: selected
                          ? AppColors.primary
                          : AppColors.border,
                      width: selected ? 2 : 1,
                    ),
                    backgroundColor: AppColors.surface,
                    labelStyle: AppTextStyles.caption.copyWith(
                      color: selected
                          ? AppColors.primary
                          : AppColors.textMuted,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(20)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
              PrimaryButton(
                label: 'Complete Setup',
                onPressed: state.isSubmitting ? null : _submit,
                isLoading: state.isSubmitting,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _BmiBadge extends StatelessWidget {
  const _BmiBadge({required this.bmi});

  final double bmi;

  Color _color() {
    if (bmi < 18.5) return AppColors.warning;
    if (bmi < 25) return AppColors.success;
    if (bmi < 30) return AppColors.warning;
    return AppColors.error;
  }

  String _label() {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return Row(
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            border: Border.all(color: color.withAlpha(100), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'BMI ${bmi.toStringAsFixed(1)}',
                style: AppTextStyles.label.copyWith(color: color),
              ),
              const SizedBox(width: 6),
              Text(
                _label(),
                style: AppTextStyles.label.copyWith(color: color),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
