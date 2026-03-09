import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/convex_provider.dart';
import '../../../../shared/router/app_router.dart';

part 'onboarding_provider.g.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class OnboardingFormState {
  const OnboardingFormState({
    this.selectedGoal,
    this.waiverAccepted = false,
    this.injuries = '',
    this.medicalConditions = '',
    this.medications = '',
    this.emergencyContactName = '',
    this.emergencyContactPhone = '',
    this.heightCm = '',
    this.weightKg = '',
    this.age = '',
    this.gender,
    this.isSubmitting = false,
    this.error,
  });

  final String? selectedGoal;
  final bool waiverAccepted;
  final String injuries;
  final String medicalConditions;
  final String medications;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String heightCm;
  final String weightKg;
  final String age;
  final String? gender;
  final bool isSubmitting;
  final String? error;

  OnboardingFormState copyWith({
    String? selectedGoal,
    bool? waiverAccepted,
    String? injuries,
    String? medicalConditions,
    String? medications,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? heightCm,
    String? weightKg,
    String? age,
    String? gender,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
    bool clearGoal = false,
    bool clearGender = false,
  }) {
    return OnboardingFormState(
      selectedGoal: clearGoal ? null : (selectedGoal ?? this.selectedGoal),
      waiverAccepted: waiverAccepted ?? this.waiverAccepted,
      injuries: injuries ?? this.injuries,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      medications: medications ?? this.medications,
      emergencyContactName:
          emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      age: age ?? this.age,
      gender: clearGender ? null : (gender ?? this.gender),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

@riverpod
class OnboardingNotifier extends _$OnboardingNotifier {
  @override
  OnboardingFormState build() {
    // Keep alive so multi-step onboarding state survives navigation between screens.
    ref.keepAlive();
    return const OnboardingFormState();
  }

  void setGoal(String goal) =>
      state = state.copyWith(selectedGoal: goal, clearError: true);

  void setWaiverAccepted(bool val) =>
      state = state.copyWith(waiverAccepted: val);

  void setAssessment({
    String? injuries,
    String? medicalConditions,
    String? medications,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) {
    state = state.copyWith(
      injuries: injuries,
      medicalConditions: medicalConditions,
      medications: medications,
      emergencyContactName: emergencyContactName,
      emergencyContactPhone: emergencyContactPhone,
      clearError: true,
    );
  }

  void setProfile({
    String? heightCm,
    String? weightKg,
    String? age,
    String? gender,
  }) {
    state = state.copyWith(
      heightCm: heightCm,
      weightKg: weightKg,
      age: age,
      gender: gender,
      clearError: true,
    );
  }

  Future<bool> submit(String userId) async {
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final client = ref.read(convexClientProvider);
      final storage = ref.read(storageServiceProvider);

      final height = double.tryParse(state.heightCm) ?? 0;
      final weight = double.tryParse(state.weightKg) ?? 0;
      final ageInt = int.tryParse(state.age) ?? 0;

      // convex_flutter SDK serializes all values via .toString() — send
      // numbers and booleans as strings so the backend receives them correctly.
      await client.mutation(name: 'mobile:submitOnboarding', args: {
        if (state.selectedGoal != null) 'goal': state.selectedGoal!,
        'waiverAccepted': state.waiverAccepted.toString(),
        if (state.injuries.trim().isNotEmpty) 'injuries': state.injuries.trim(),
        if (state.medicalConditions.trim().isNotEmpty)
          'medicalConditions': state.medicalConditions.trim(),
        if (state.medications.trim().isNotEmpty)
          'medications': state.medications.trim(),
        if (state.emergencyContactName.trim().isNotEmpty)
          'emergencyContactName': state.emergencyContactName.trim(),
        if (state.emergencyContactPhone.trim().isNotEmpty)
          'emergencyContactPhone': state.emergencyContactPhone.trim(),
        if (height > 0) 'heightCm': height.toString(),
        if (weight > 0) 'weightKg': weight.toString(),
        if (ageInt > 0) 'age': ageInt.toString(),
        if (state.gender != null) 'gender': state.gender!,
      });

      await storage.saveOnboardingComplete(userId);
      ref.read(appInitProvider.notifier).state = AppInitState.ready;
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Setup failed. Please try again.',
      );
      return false;
    }
  }
}
