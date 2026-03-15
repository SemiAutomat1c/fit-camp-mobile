/// Lightweight member snapshot returned by [getMyMembers].
///
/// Used on create-plan screens so the trainer can pick a member from
/// their assigned list without loading full profile data.
class MemberSummary {
  const MemberSummary({
    required this.id,
    required this.name,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String? avatarUrl;

  factory MemberSummary.fromJson(Map<String, dynamic> json) => MemberSummary(
        id: json['_id'] as String,
        name: json['name'] as String,
        avatarUrl: json['avatarUrl'] as String?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is MemberSummary && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
