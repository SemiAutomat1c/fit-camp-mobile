import 'dart:typed_data';

import '../domain/entities/progress_log.dart';

/// Abstract contract for progress data access.
abstract class ProgressRepository {
  Future<List<ProgressLog>> getMyProgress();

  /// Returns the member's height in centimetres from their profile.
  /// Returns null if height is not set.
  Future<double?> getMyHeightCm();

  /// Requests a presigned Convex storage upload URL.
  Future<String> generateUploadUrl();

  /// Uploads [bytes] as JPEG to [uploadUrl] and returns the Convex storageId.
  Future<String> uploadImage(String uploadUrl, Uint8List bytes);

  Future<String> logProgress({
    required int dateMs,
    double? weight,
    double? bmi,
    String? notes,
    String? photoStorageId,
  });
}
