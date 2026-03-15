import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../data/convex_training_repository.dart';
import '../providers/training_provider.dart';

// ---------------------------------------------------------------------------
// Local data class — one entry per meal row
// ---------------------------------------------------------------------------

class _MealEntry {
  _MealEntry()
      : name = TextEditingController(),
        time = TextEditingController(),
        foods = TextEditingController(),
        calories = TextEditingController(),
        notes = TextEditingController();

  final TextEditingController name;
  final TextEditingController time;

  /// Comma-separated food items. Split and trimmed on submit.
  final TextEditingController foods;
  final TextEditingController calories;
  final TextEditingController notes;

  void dispose() {
    name.dispose();
    time.dispose();
    foods.dispose();
    calories.dispose();
    notes.dispose();
  }
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class CreateDietPlanScreen extends ConsumerStatefulWidget {
  const CreateDietPlanScreen({super.key});

  @override
  ConsumerState<CreateDietPlanScreen> createState() =>
      _CreateDietPlanScreenState();
}

class _CreateDietPlanScreenState extends ConsumerState<CreateDietPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  String? _selectedMemberId;

  final List<_MealEntry> _meals = [_MealEntry()];

  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    for (final m in _meals) {
      m.dispose();
    }
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  InputDecoration _fieldDecoration({
    required String hint,
    String? helperText,
  }) {
    return InputDecoration(
      hintText: hint,
      helperText: helperText,
      helperStyle: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
      hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  void _addMeal() {
    setState(() => _meals.add(_MealEntry()));
  }

  void _removeMeal(int index) {
    if (_meals.length <= 1) return;
    setState(() {
      final entry = _meals.removeAt(index);
      entry.dispose();
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedMemberId == null) {
      AppSnackbar.error(context, 'Please select a member.');
      return;
    }

    // Gather and validate meal entries
    final mealData = <Map<String, dynamic>>[];
    for (final entry in _meals) {
      final nameText = entry.name.text.trim();
      if (nameText.isEmpty) {
        AppSnackbar.error(
          context,
          'Each meal must have a name. Fill in all meal names.',
        );
        return;
      }
      final timeText = entry.time.text.trim();
      if (timeText.isEmpty) {
        AppSnackbar.error(
          context,
          'Each meal must have a time (e.g. "7:00 AM").',
        );
        return;
      }
      final foodsText = entry.foods.text.trim();
      final foodList = foodsText
          .split(',')
          .map((f) => f.trim())
          .where((f) => f.isNotEmpty)
          .toList();
      if (foodList.isEmpty) {
        AppSnackbar.error(
          context,
          'Meal "$nameText" must have at least one food item.',
        );
        return;
      }

      final map = <String, dynamic>{
        'name': nameText,
        'time': timeText,
        'foods': foodList,
      };

      final caloriesText = entry.calories.text.trim();
      if (caloriesText.isNotEmpty) {
        final parsed = int.tryParse(caloriesText);
        if (parsed != null && parsed > 0) map['calories'] = parsed;
      }

      final notesText = entry.notes.text.trim();
      if (notesText.isNotEmpty) map['notes'] = notesText;

      mealData.add(map);
    }

    setState(() => _isSaving = true);

    try {
      await ref.read(trainingRepositoryProvider).createDietPlan(
            memberId: _selectedMemberId!,
            name: _nameController.text.trim(),
            description: _descController.text.trim().isEmpty
                ? null
                : _descController.text.trim(),
            meals: mealData,
          );

      await HapticFeedback.mediumImpact();
      ref.invalidate(dietPlansProvider);

      if (mounted) {
        AppSnackbar.success(context, 'Diet plan created!');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        final raw = e.toString();
        final message = raw.contains('ConvexError')
            ? raw.replaceAll(RegExp(r'.*ConvexError:\s*'), '').trim()
            : 'Failed to create plan. Please try again.';
        AppSnackbar.error(context, message);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(myMembersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Create Diet Plan',
          style:
              AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            // ── Plan name ────────────────────────────────────────────────────
            Text(
              'Plan Name',
              style: AppTextStyles.label.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
              decoration: _fieldDecoration(hint: 'e.g. High-Protein Meal Plan'),
              textCapitalization: TextCapitalization.words,
              validator: (v) {
                if (v == null || v.trim().length < 2) {
                  return 'Plan name must be at least 2 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // ── Description ──────────────────────────────────────────────────
            Text(
              'Description (optional)',
              style: AppTextStyles.label.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descController,
              style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
              decoration: _fieldDecoration(
                hint: 'Brief description of the plan...',
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 20),

            // ── Member picker ─────────────────────────────────────────────────
            Text(
              'Assign to Member',
              style: AppTextStyles.label.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 8),
            membersAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                ),
              ),
              error: (_, __) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Could not load members. Pull to refresh.',
                  style:
                      AppTextStyles.caption.copyWith(color: AppColors.error),
                ),
              ),
              data: (members) => DropdownButtonFormField<String>(
                value: _selectedMemberId,
                dropdownColor: AppColors.elevated,
                style:
                    AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                decoration: _fieldDecoration(hint: 'Select a member'),
                hint: Text(
                  'Select a member',
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.textMuted),
                ),
                items: members
                    .map(
                      (m) => DropdownMenuItem<String>(
                        value: m.id,
                        child: Text(
                          m.name,
                          style: AppTextStyles.body
                              .copyWith(color: AppColors.textPrimary),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMemberId = value;
                  });
                },
                validator: (_) => _selectedMemberId == null
                    ? 'Please select a member'
                    : null,
              ),
            ),
            const SizedBox(height: 28),

            // ── Meals section ────────────────────────────────────────────────
            Row(
              children: [
                Text(
                  'Meals',
                  style: AppTextStyles.heading4
                      .copyWith(color: AppColors.textPrimary),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _addMeal,
                  child: Text(
                    'Add Meal',
                    style: AppTextStyles.bodyMed
                        .copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...List.generate(_meals.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _MealCard(
                  entry: _meals[index],
                  index: index,
                  canRemove: _meals.length > 1,
                  onRemove: () => _removeMeal(index),
                  fieldDecoration: _fieldDecoration,
                ),
              );
            }),
            const SizedBox(height: 8),

            // ── Submit ───────────────────────────────────────────────────────
            PrimaryButton(
              label: 'Create Plan',
              isLoading: _isSaving,
              onPressed: _isSaving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Meal card widget
// ---------------------------------------------------------------------------

class _MealCard extends StatelessWidget {
  const _MealCard({
    required this.entry,
    required this.index,
    required this.canRemove,
    required this.onRemove,
    required this.fieldDecoration,
  });

  final _MealEntry entry;
  final int index;
  final bool canRemove;
  final VoidCallback onRemove;
  final InputDecoration Function({required String hint, String? helperText})
      fieldDecoration;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.elevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Row(
            children: [
              Text(
                'Meal ${index + 1}',
                style: AppTextStyles.bodyMed
                    .copyWith(color: AppColors.textPrimary),
              ),
              const Spacer(),
              if (canRemove)
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    color: AppColors.error,
                    size: 22,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Remove meal',
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Meal name (required)
          TextFormField(
            controller: entry.name,
            style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
            decoration: fieldDecoration(hint: 'Meal name (e.g. Breakfast)'),
            textCapitalization: TextCapitalization.words,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Meal name is required' : null,
          ),
          const SizedBox(height: 12),

          // Meal time (required)
          TextFormField(
            controller: entry.time,
            style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
            decoration: fieldDecoration(hint: 'Time (e.g. 7:00 AM)'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Meal time is required' : null,
          ),
          const SizedBox(height: 12),

          // Foods (required, comma-separated)
          TextFormField(
            controller: entry.foods,
            style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
            decoration: fieldDecoration(
              hint: 'e.g. Eggs, Oatmeal, Banana',
              helperText: 'Separate foods with commas',
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 12),

          // Calories (optional)
          TextFormField(
            controller: entry.calories,
            style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
            decoration: fieldDecoration(hint: 'Calories (optional)'),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 12),

          // Notes (optional)
          TextFormField(
            controller: entry.notes,
            style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
            decoration: fieldDecoration(hint: 'Notes (optional)'),
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ),
    );
  }
}
