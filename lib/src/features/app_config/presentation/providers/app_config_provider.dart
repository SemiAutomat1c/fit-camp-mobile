import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/convex_app_config_repository.dart';
import '../../domain/entities/app_config.dart';

part 'app_config_provider.g.dart';

@riverpod
Future<AppConfig> appConfig(AppConfigRef ref) async {
  final repo = ref.watch(appConfigRepositoryProvider);
  return repo.getAppConfig();
}
