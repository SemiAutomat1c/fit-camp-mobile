import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../training/domain/entities/member_summary.dart';
import '../../data/convex_trainer_repository.dart';

part 'trainer_provider.g.dart';

@riverpod
Future<List<MemberSummary>> trainerClients(TrainerClientsRef ref) async {
  final repo = ref.read(trainerRepositoryProvider);
  return repo.getMyMembers();
}
