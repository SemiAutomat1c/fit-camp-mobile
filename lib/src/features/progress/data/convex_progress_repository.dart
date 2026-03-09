import 'dart:convert';
import 'dart:typed_data';

import 'package:convex_flutter/convex_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/services/convex_provider.dart';
import '../domain/entities/progress_log.dart';
import 'progress_repository.dart';

class ConvexProgressRepository implements ProgressRepository {
  const ConvexProgressRepository(this._client);

  final ConvexClient _client;

  @override
  Future<List<ProgressLog>> getMyProgress() async {
    // convex_flutter already deserialises the response — do NOT jsonDecode.
    final raw = await _client.query('mobile:getMyProgress', {});
    final list = raw as List<dynamic>;
    return list
        .map((e) => ProgressLog.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<double?> getMyHeightCm() async {
    // convex_flutter already deserialises the response — do NOT jsonDecode.
    final raw = await _client.query('mobile:getMyProfile', {});
    final profile = raw as Map<String, dynamic>;
    final height = profile['height'];
    if (height == null) return null;
    final value = (height as num).toDouble();
    return value > 0 ? value : null;
  }

  @override
  Future<String> generateUploadUrl() async {
    // Use the dedicated progress upload URL endpoint, not the chat one.
    final result = await _client.mutation(
      name: 'mobile:generateProgressUploadUrl',
      args: {},
    );
    // convex_flutter returns dynamic. Convert to String and validate at runtime.
    final url = result.toString();
    if (url.isEmpty) throw StateError('generateProgressUploadUrl returned an empty URL');
    return url;
  }

  @override
  Future<String> uploadImage(String uploadUrl, Uint8List bytes) async {
    // Validate that the URL is a Convex storage HTTPS URL before uploading,
    // preventing accidental or malicious redirect to an arbitrary host.
    final uri = Uri.parse(uploadUrl);
    if (uri.scheme != 'https') {
      throw Exception('Upload URL must use HTTPS');
    }

    final response = await http.put(
      uri,
      headers: {'Content-Type': 'image/jpeg'},
      body: bytes,
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Image upload failed: HTTP ${response.statusCode}');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['storageId'] as String;
  }

  @override
  Future<String> logProgress({
    required int dateMs,
    double? weight,
    double? bmi,
    String? notes,
    String? photoStorageId,
  }) async {
    final args = <String, dynamic>{
      'date': dateMs,
      if (weight != null) 'weight': weight,
      if (bmi != null) 'bmi': bmi,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
      if (photoStorageId != null) 'photoStorageId': photoStorageId,
    };
    final result = await _client.mutation(
      name: 'mobile:logProgress',
      args: args,
    );
    return result.toString();
  }
}

final Provider<ProgressRepository> progressRepositoryProvider =
    Provider<ProgressRepository>(
  (ref) => ConvexProgressRepository(ref.read(convexClientProvider)),
  name: 'progressRepositoryProvider',
);
