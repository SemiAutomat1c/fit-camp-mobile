import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../providers/edit_profile_provider.dart';
import '../providers/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _heightCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _ageCtrl;
  bool _initialized = false;

  static const _goals = [
    ('gain_muscle', 'Gain Muscle'),
    ('lose_weight', 'Lose Weight'),
    ('improve_endurance', 'Improve Endurance'),
    ('general_fitness', 'General Fitness'),
    ('sports_performance', 'Sports Performance'),
  ];

  static const _genders = [
    ('male', 'Male'),
    ('female', 'Female'),
    ('other', 'Other'),
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _heightCtrl = TextEditingController();
    _weightCtrl = TextEditingController();
    _ageCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  void _init(Map<String, dynamic> profile) {
    if (_initialized) return;
    _initialized = true;
    final notifier = ref.read(editProfileNotifierProvider.notifier);
    notifier.init(profile);
    final s = ref.read(editProfileNotifierProvider);
    _nameCtrl.text = s.name;
    _phoneCtrl.text = s.phone;
    _heightCtrl.text = s.height;
    _weightCtrl.text = s.weight;
    _ageCtrl.text = s.age;
  }

  Future<void> _submit() async {
    HapticFeedback.mediumImpact();
    final success =
        await ref.read(editProfileNotifierProvider.notifier).submit();
    if (!mounted) return;
    if (success) {
      AppSnackbar.success(context, 'Profile updated!');
      context.pop();
    } else {
      final error = ref.read(editProfileNotifierProvider).error;
      AppSnackbar.error(context, error ?? 'Update failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(myProfileProvider);
    final notifier = ref.read(editProfileNotifierProvider.notifier);
    final editState = ref.watch(editProfileNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Edit Profile'),
      ),
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (_, __) => const Center(
          child: Text('Could not load profile.',
              style: TextStyle(color: AppColors.textMuted)),
        ),
        data: (profile) {
          if (profile != null) _init(profile);
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  controller: _nameCtrl,
                  label: 'Full Name',
                  onChanged: notifier.setName,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _phoneCtrl,
                  label: 'Phone Number',
                  keyboardType: TextInputType.phone,
                  onChanged: notifier.setPhone,
                ),
                const SizedBox(height: 24),
                Text('Fitness Goal',
                    style: AppTextStyles.label
                        .copyWith(color: AppColors.textMuted)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _goals.map((g) {
                    final selected = editState.goal == g.$1;
                    return FilterChip(
                      label: Text(g.$2),
                      selected: selected,
                      onSelected: (_) => notifier.setGoal(g.$1),
                      selectedColor: AppColors.primary.withAlpha(38),
                      checkmarkColor: AppColors.primary,
                      labelStyle: AppTextStyles.label.copyWith(
                        color:
                            selected ? AppColors.primary : AppColors.textMuted,
                      ),
                      side: BorderSide(
                        color: selected
                            ? AppColors.primary.withAlpha(120)
                            : AppColors.border,
                      ),
                      backgroundColor: AppColors.elevated,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                Text('Gender',
                    style: AppTextStyles.label
                        .copyWith(color: AppColors.textMuted)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: _genders.map((g) {
                    final selected = editState.gender == g.$1;
                    return FilterChip(
                      label: Text(g.$2),
                      selected: selected,
                      onSelected: (_) => notifier.setGender(g.$1),
                      selectedColor: AppColors.primary.withAlpha(38),
                      checkmarkColor: AppColors.primary,
                      labelStyle: AppTextStyles.label.copyWith(
                        color:
                            selected ? AppColors.primary : AppColors.textMuted,
                      ),
                      side: BorderSide(
                        color: selected
                            ? AppColors.primary.withAlpha(120)
                            : AppColors.border,
                      ),
                      backgroundColor: AppColors.elevated,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _heightCtrl,
                        label: 'Height (cm)',
                        keyboardType: TextInputType.number,
                        onChanged: notifier.setHeight,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        controller: _weightCtrl,
                        label: 'Weight (kg)',
                        keyboardType: TextInputType.number,
                        onChanged: notifier.setWeight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _ageCtrl,
                  label: 'Age',
                  keyboardType: TextInputType.number,
                  onChanged: notifier.setAge,
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  label: 'Save Changes',
                  isLoading: editState.isSubmitting,
                  onPressed: editState.isSubmitting ? null : _submit,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
