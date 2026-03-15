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
// Local data class — one entry per exercise row
// ---------------------------------------------------------------------------

class _ExerciseEntry {
  _ExerciseEntry()
      : name = TextEditingController(),
        sets = TextEditingController(),
        reps = TextEditingController(),
        duration = TextEditingController(),
        notes = TextEditingController();

  final TextEditingController name;
  final TextEditingController sets;
  final TextEditingController reps;
  final TextEditingController duration;
  final TextEditingController notes;

  void dispose() {
    name.dispose();
    sets.dispose();
    reps.dispose();
    duration.dispose();
    notes.dispose();
  }
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class CreateWorkoutPlanScreen extends ConsumerStatefulWidget {
  const CreateWorkoutPlanScreen({super.key});

  @override
  ConsumerState<CreateWorkoutPlanScreen> createState() =>
      _CreateWorkoutPlanScreenState();
}

class _CreateWorkoutPlanScreenState
    extends ConsumerState<CreateWorkoutPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  String? _selectedMemberId;

  final List<_ExerciseEntry> _exercises = [_ExerciseEntry()];

  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    for (final e in _exercises) {
      e.dispose();
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

  void _addExercise() {
    setState(() => _exercises.add(_ExerciseEntry()));
  }

  void _removeExercise(int index) {
    if (_exercises.length <= 1) return;
    setState(() {
      final entry = _exercises.removeAt(index);
      entry.dispose();
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedMemberId == null) {
      AppSnackbar.error(context, 'Please select a member.');
      return;
    }

    // Gather and validate exercise entries
    final exerciseData = <Map<String, dynamic>>[];
    for (final entry in _exercises) {
      final nameText = entry.name.text.trim();
      if (nameText.isEmpty) {
        AppSnackbar.error(
          context,
          'Each exercise must have a name. Fill in all exercise names.',
        );
        return;
      }
      final map = <String, dynamic>{'name': nameText};
      final setsText = entry.sets.text.trim();
      if (setsText.isNotEmpty) {
        final parsed = int.tryParse(setsText);
        if (parsed != null && parsed > 0) map['sets'] = parsed;
      }
      final repsText = entry.reps.text.trim();
      if (repsText.isNotEmpty) {
        final parsed = int.tryParse(repsText);
        if (parsed != null && parsed > 0) map['reps'] = parsed;
      }
      final durationText = entry.duration.text.trim();
      if (durationText.isNotEmpty) map['duration'] = durationText;
      final notesText = entry.notes.text.trim();
      if (notesText.isNotEmpty) map['notes'] = notesText;
      exerciseData.add(map);
    }

    setState(() => _isSaving = true);

    try {
      await ref.read(trainingRepositoryProvider).createTrainingPlan(
            memberId: _selectedMemberId!,
            name: _nameController.text.trim(),
            description: _descController.text.trim().isEmpty
                ? null
                : _descController.text.trim(),
            exercises: exerciseData,
          );

      await HapticFeedback.mediumImpact();
      ref.invalidate(trainingPlansProvider);

      if (mounted) {
        AppSnackbar.success(context, 'Workout plan created!');
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
          'Create Workout Plan',
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
              decoration: _fieldDecoration(hint: 'e.g. Upper Body Strength'),
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

            // ── Exercises section ────────────────────────────────────────────
            Row(
              children: [
                Text(
                  'Exercises',
                  style: AppTextStyles.heading4
                      .copyWith(color: AppColors.textPrimary),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _addExercise,
                  child: Text(
                    'Add Exercise',
                    style: AppTextStyles.bodyMed
                        .copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...List.generate(_exercises.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _ExerciseCard(
                  entry: _exercises[index],
                  index: index,
                  canRemove: _exercises.length > 1,
                  onRemove: () => _removeExercise(index),
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
// Exercise card widget
// ---------------------------------------------------------------------------

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.entry,
    required this.index,
    required this.canRemove,
    required this.onRemove,
    required this.fieldDecoration,
  });

  final _ExerciseEntry entry;
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
                'Exercise ${index + 1}',
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
                  tooltip: 'Remove exercise',
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Name (required)
          TextFormField(
            controller: entry.name,
            style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
            decoration: fieldDecoration(hint: 'Exercise name (required)'),
            textCapitalization: TextCapitalization.words,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Exercise name is required' : null,
          ),
          const SizedBox(height: 12),

          // Sets + Reps row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: entry.sets,
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.textPrimary),
                  decoration: fieldDecoration(hint: 'Sets'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: entry.reps,
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.textPrimary),
                  decoration: fieldDecoration(hint: 'Reps'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Duration (optional, text)
          TextFormField(
            controller: entry.duration,
            style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
            decoration: fieldDecoration(
              hint: 'Duration (e.g. 30 sec)',
            ),
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
