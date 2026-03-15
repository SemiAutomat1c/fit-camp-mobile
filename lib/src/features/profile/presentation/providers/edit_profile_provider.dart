import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/convex_profile_repository.dart';
import '../providers/profile_provider.dart';

part 'edit_profile_provider.g.dart';

class EditProfileState {
  const EditProfileState({
    this.name = '',
    this.phone = '',
    this.goal,
    this.height = '',
    this.weight = '',
    this.age = '',
    this.gender,
    this.avatarUrl,
    this.isSubmitting = false,
    this.error,
  });

  final String name;
  final String phone;
  final String? goal;
  final String height;
  final String weight;
  final String age;
  final String? gender;
  final String? avatarUrl;
  final bool isSubmitting;
  final String? error;

  EditProfileState copyWith({
    String? name,
    String? phone,
    String? goal,
    String? height,
    String? weight,
    String? age,
    String? gender,
    String? avatarUrl,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
    bool clearGoal = false,
    bool clearGender = false,
  }) {
    return EditProfileState(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      goal: clearGoal ? null : (goal ?? this.goal),
      height: height ?? this.height,
      weight: weight ?? this.weight,
      age: age ?? this.age,
      gender: clearGender ? null : (gender ?? this.gender),
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

@riverpod
class EditProfileNotifier extends _$EditProfileNotifier {
  @override
  EditProfileState build() => const EditProfileState();

  void init(Map<String, dynamic> profile) {
    state = EditProfileState(
      name: (profile['user']?['name'] as String?) ?? '',
      phone: (profile['user']?['phone'] as String?) ?? '',
      goal: profile['goal'] as String?,
      height: (profile['height'] as num?)?.toInt().toString() ?? '',
      weight: (profile['weight'] as num?)?.toInt().toString() ?? '',
      age: (profile['age'] as num?)?.toInt().toString() ?? '',
      gender: profile['gender'] as String?,
      avatarUrl: profile['user']?['avatarUrl'] as String?,
    );
  }

  void setName(String v) => state = state.copyWith(name: v, clearError: true);
  void setPhone(String v) => state = state.copyWith(phone: v, clearError: true);
  void setGoal(String v) => state = state.copyWith(goal: v, clearError: true);
  void setHeight(String v) =>
      state = state.copyWith(height: v, clearError: true);
  void setWeight(String v) =>
      state = state.copyWith(weight: v, clearError: true);
  void setAge(String v) => state = state.copyWith(age: v, clearError: true);
  void setGender(String v) =>
      state = state.copyWith(gender: v, clearError: true);
  void setAvatarUrl(String? v) => state = state.copyWith(avatarUrl: v);

  Future<bool> submit() async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final repo = ref.read(profileRepositoryProvider);
      await repo.updateProfile(
        name: state.name.trim().isNotEmpty ? state.name.trim() : null,
        phone: state.phone.trim().isNotEmpty ? state.phone.trim() : null,
        avatarUrl: state.avatarUrl,
        goal: state.goal,
        height: int.tryParse(state.height),
        weight: int.tryParse(state.weight),
        age: int.tryParse(state.age),
        gender: state.gender,
      );
      ref.invalidate(myProfileProvider);
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Failed to update profile. Please try again.',
      );
      return false;
    }
  }
}
