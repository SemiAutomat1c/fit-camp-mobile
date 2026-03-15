import 'dart:convert';

import 'package:convex_flutter/convex_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/convex_provider.dart';
import '../domain/entities/app_config.dart';
import 'app_config_repository.dart';

class ConvexAppConfigRepository implements AppConfigRepository {
  const ConvexAppConfigRepository(this._client);

  final ConvexClient _client;

  @override
  Future<AppConfig> getAppConfig() async {
    final raw = await _client.query('mobile:getAppConfig', {});
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return AppConfig(
      minimumVersion: json['minimumVersion'] as String? ?? '1.0.0',
      maintenanceMode: json['maintenanceMode'] as bool? ?? false,
      maintenanceMessage: json['maintenanceMessage'] as String?,
    );
  }
}

final Provider<AppConfigRepository> appConfigRepositoryProvider =
    Provider<AppConfigRepository>(
  (ref) => ConvexAppConfigRepository(ref.read(convexClientProvider)),
  name: 'appConfigRepositoryProvider',
);
