import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_text_styles.dart';
import '../../../../../shared/widgets/app_text_field.dart';
import '../../../../../shared/widgets/primary_button.dart';
import '../../providers/onboarding_provider.dart';
import 'goal_selection_screen.dart';

class PreAssessmentScreen extends ConsumerStatefulWidget {
  const PreAssessmentScreen({super.key});

  @override
  ConsumerState<PreAssessmentScreen> createState() =>
      _PreAssessmentScreenState();
}

class _PreAssessmentScreenState
    extends ConsumerState<PreAssessmentScreen> {
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _injuriesController = TextEditingController();
  final _medicalController = TextEditingController();
  final _medicationsController = TextEditingController();

  final _emergencyNameFocus = FocusNode();
  final _emergencyPhoneFocus = FocusNode();
  final _injuriesFocus = FocusNode();
  final _medicalFocus = FocusNode();
  final _medicationsFocus = FocusNode();

  bool get _canProceed =>
      _emergencyNameController.text.trim().isNotEmpty &&
      _emergencyPhoneController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _emergencyNameController.addListener(_rebuild);
    _emergencyPhoneController.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _emergencyNameController.removeListener(_rebuild);
    _emergencyPhoneController.removeListener(_rebuild);

    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _injuriesController.dispose();
    _medicalController.dispose();
    _medicationsController.dispose();

    _emergencyNameFocus.dispose();
    _emergencyPhoneFocus.dispose();
    _injuriesFocus.dispose();
    _medicalFocus.dispose();
    _medicationsFocus.dispose();
    super.dispose();
  }

  void _onNext() {
    ref.read(onboardingNotifierProvider.notifier).setAssessment(
          emergencyContactName: _emergencyNameController.text.trim(),
          emergencyContactPhone: _emergencyPhoneController.text.trim(),
          injuries: _injuriesController.text,
          medicalConditions: _medicalController.text,
          medications: _medicationsController.text,
        );
    context.push('/onboarding/profile-setup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const OnboardingStepIndicator(
                  currentStep: 3, totalSteps: 4),
              const SizedBox(height: 32),
              Text(
                'Health Assessment',
                style: AppTextStyles.heading2
                    .copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Help us keep you safe during training.',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 32),
              Text(
                'Emergency Contact',
                style: AppTextStyles.heading4
                    .copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Full Name',
                hint: 'Emergency contact name',
                controller: _emergencyNameController,
                focusNode: _emergencyNameFocus,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) =>
                    _emergencyPhoneFocus.requestFocus(),
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Phone Number',
                hint: '+1 555 000 0000',
                controller: _emergencyPhoneController,
                focusNode: _emergencyPhoneFocus,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) =>
                    _injuriesFocus.requestFocus(),
              ),
              const SizedBox(height: 24),
              Text(
                'Medical History',
                style: AppTextStyles.heading4
                    .copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                'Optional — leave blank if not applicable.',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 12),
              _MultilineField(
                label: 'Current Injuries',
                hint: 'Describe any current injuries or pain areas...',
                controller: _injuriesController,
                focusNode: _injuriesFocus,
                nextFocus: _medicalFocus,
              ),
              const SizedBox(height: 12),
              _MultilineField(
                label: 'Medical Conditions',
                hint: 'E.g., asthma, diabetes, heart conditions...',
                controller: _medicalController,
                focusNode: _medicalFocus,
                nextFocus: _medicationsFocus,
              ),
              const SizedBox(height: 12),
              _MultilineField(
                label: 'Medications',
                hint: 'List any medications that may affect exercise...',
                controller: _medicationsController,
                focusNode: _medicationsFocus,
                nextFocus: null,
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Next',
                onPressed: _canProceed ? _onNext : null,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _MultilineField extends StatelessWidget {
  const _MultilineField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.focusNode,
    required this.nextFocus,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? nextFocus;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor =
        isDark ? AppColors.surface : const Color(0xFFFFFFFF);
    final borderColor =
        isDark ? AppColors.border : const Color(0xFFDDDDDD);
    final focusColor =
        isDark ? AppColors.primary : const Color(0xFF2DB80F);
    final textColor =
        isDark ? AppColors.textPrimary : const Color(0xFF0A0A0A);
    final hintColor =
        isDark ? AppColors.textMuted : const Color(0xFF555555);

    final border = OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: borderColor, width: 1),
    );

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      maxLines: 3,
      textInputAction:
          nextFocus != null ? TextInputAction.next : TextInputAction.done,
      onFieldSubmitted: (_) => nextFocus?.requestFocus(),
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: textColor,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: fillColor,
        hintStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.5,
            color: hintColor),
        labelStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.5,
            color: hintColor),
        floatingLabelStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.4,
            color: focusColor),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: border,
        enabledBorder: border,
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: focusColor, width: 2),
        ),
      ),
    );
  }
}
