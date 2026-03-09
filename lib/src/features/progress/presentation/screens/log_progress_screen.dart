import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../data/convex_progress_repository.dart';
import '../providers/progress_provider.dart';

/// Form screen to log a new progress entry.
///
/// Fields:
///  - Date (date picker, defaults to today)
///  - Weight (required, numeric kg)
///  - Auto-calculated BMI (read-only)
///  - Notes (optional, multiline, 500 char max)
///  - Photo (optional, image_picker)
class LogProgressScreen extends ConsumerStatefulWidget {
  const LogProgressScreen({super.key});

  @override
  ConsumerState<LogProgressScreen> createState() => _LogProgressScreenState();
}

class _LogProgressScreenState extends ConsumerState<LogProgressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  XFile? _selectedPhoto;
  Uint8List? _photoBytes;
  bool _isSaving = false;
  double? _calculatedBmi;

  @override
  void initState() {
    super.initState();
    _weightController.addListener(_recalcBmi);
  }

  @override
  void dispose() {
    _weightController.removeListener(_recalcBmi);
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _recalcBmi() {
    final heightAsync = ref.read(memberHeightCmProvider);
    final heightCm = heightAsync.valueOrNull;
    if (heightCm == null || heightCm <= 0) {
      if (_calculatedBmi != null) setState(() => _calculatedBmi = null);
      return;
    }
    final weightText = _weightController.text.trim();
    final weight = double.tryParse(weightText);
    if (weight == null || weight <= 0) {
      if (_calculatedBmi != null) setState(() => _calculatedBmi = null);
      return;
    }
    final heightM = heightCm / 100.0;
    final bmi = weight / (heightM * heightM);
    setState(() => _calculatedBmi = bmi);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.background,
              surface: AppColors.elevated,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  /// Maximum allowed photo size before upload (10 MB).
  static const int _maxPhotoBytes = 10 * 1024 * 1024;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1080,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();

    if (bytes.length > _maxPhotoBytes) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Photo is too large. Please choose an image under 10 MB.');
      return;
    }

    setState(() {
      _selectedPhoto = file;
      _photoBytes = bytes;
    });
  }

  void _removePhoto() {
    setState(() {
      _selectedPhoto = null;
      _photoBytes = null;
    });
  }

  void _showImageSourceSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.elevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.textPrimary),
              title: Text(
                'Camera',
                style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.textPrimary),
              title: Text(
                'Photo Library',
                style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(progressRepositoryProvider);
      final weight = double.parse(_weightController.text.trim());
      final notes = _notesController.text.trim();
      final dateMs = _selectedDate.millisecondsSinceEpoch;

      String? photoStorageId;
      if (_selectedPhoto != null && _photoBytes != null) {
        final uploadUrl = await repo.generateUploadUrl();
        photoStorageId = await repo.uploadImage(uploadUrl, _photoBytes!);
      }

      await repo.logProgress(
        dateMs: dateMs,
        weight: weight,
        bmi: _calculatedBmi,
        notes: notes.isNotEmpty ? notes : null,
        photoStorageId: photoStorageId,
      );

      if (!mounted) return;

      HapticFeedback.mediumImpact();
      ref.invalidate(progressLogsProvider);
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      // Do not expose raw exception internals to the user.
      AppSnackbar.error(context, 'Failed to save progress. Please try again.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final heightAsync = ref.watch(memberHeightCmProvider);
    final heightCm = heightAsync.valueOrNull;
    final heightUnavailable = heightCm == null || heightCm <= 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Log Progress',
          style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Date picker
              _FieldLabel(label: 'Date'),
              const SizedBox(height: 8),
              _DatePickerRow(
                date: _selectedDate,
                onTap: _pickDate,
              ),
              const SizedBox(height: 20),

              // Weight input
              _FieldLabel(label: 'Weight (kg)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                decoration: _inputDecoration(hint: '70.5'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Weight is required';
                  }
                  final parsed = double.tryParse(value.trim());
                  if (parsed == null || parsed <= 0) {
                    return 'Enter a valid weight';
                  }
                  if (parsed < 20 || parsed > 500) {
                    return 'Enter a weight between 20 and 500 kg';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // BMI (read-only)
              _FieldLabel(label: 'BMI (auto-calculated)'),
              const SizedBox(height: 8),
              _BmiReadonlyField(
                bmi: _calculatedBmi,
                heightUnavailable: heightUnavailable,
              ),
              const SizedBox(height: 20),

              // Notes
              _FieldLabel(label: 'Notes (optional)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                maxLength: 500,
                style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                decoration: _inputDecoration(hint: 'How are you feeling today?'),
              ),
              const SizedBox(height: 20),

              // Photo section
              _FieldLabel(label: 'Progress Photo (optional)'),
              const SizedBox(height: 8),
              _PhotoSection(
                photoBytes: _photoBytes,
                onAddPhoto: _showImageSourceSheet,
                onRemove: _removePhoto,
              ),
              const SizedBox(height: 32),

              PrimaryButton(
                label: 'Save Progress',
                onPressed: _isSaving ? null : _save,
                isLoading: _isSaving,
                icon: Icons.save_alt,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.bodyMed.copyWith(color: AppColors.textPrimary),
    );
  }
}

class _DatePickerRow extends StatelessWidget {
  const _DatePickerRow({required this.date, required this.onTap});

  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppColors.primary, size: 18),
            const SizedBox(width: 12),
            Text(
              DateFormat('EEEE, d MMMM yyyy').format(date),
              style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

class _BmiReadonlyField extends StatelessWidget {
  const _BmiReadonlyField({
    required this.bmi,
    required this.heightUnavailable,
  });

  final double? bmi;
  final bool heightUnavailable;

  @override
  Widget build(BuildContext context) {
    final String displayText;
    if (heightUnavailable) {
      displayText = 'Set height in profile to auto-calculate BMI';
    } else if (bmi == null) {
      displayText = 'Enter weight above to calculate';
    } else {
      displayText = bmi!.toStringAsFixed(2);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.elevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        displayText,
        style: AppTextStyles.body.copyWith(
          color: bmi != null ? AppColors.primary : AppColors.textMuted,
        ),
      ),
    );
  }
}

class _PhotoSection extends StatelessWidget {
  const _PhotoSection({
    required this.photoBytes,
    required this.onAddPhoto,
    required this.onRemove,
  });

  final Uint8List? photoBytes;
  final VoidCallback onAddPhoto;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    if (photoBytes != null) {
      return Stack(
        alignment: Alignment.topRight,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              photoBytes!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(178),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: onAddPhoto,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_a_photo_outlined, color: AppColors.primary, size: 32),
            const SizedBox(height: 8),
            Text(
              'Add Photo',
              style: AppTextStyles.bodyMed.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 4),
            Text(
              'Camera or Gallery',
              style: AppTextStyles.label.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
