/// Roles available in the 24 Fit Camp system.
enum AppUserRole {
  member,
  trainer,
  admin;

  /// Parses a role string from storage or the Convex backend.
  /// Defaults to [AppUserRole.member] for unknown values.
  static AppUserRole fromString(String value) {
    return AppUserRole.values.firstWhere(
      (r) => r.name == value,
      orElse: () => AppUserRole.member,
    );
  }
}

/// Authenticated user entity returned by the Convex backend.
///
/// This is a plain Dart class — Freezed code generation is added in Sprint 1
/// when all models are finalized. [fromJson] and [toJson] are hand-rolled to
/// avoid the build_runner dependency in Sprint 0.
class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.isActive,
    required this.createdAt,
    this.avatarUrl,
  });

  /// Convex document ID (e.g. `'j97abc123'`)
  final String id;

  /// Full display name
  final String name;

  /// Email address
  final String email;

  /// Phone number (international format preferred)
  final String phone;

  /// User's access role
  final AppUserRole role;

  /// URL to the user's profile photo, or null if not set
  final String? avatarUrl;

  /// Whether the account is active (not suspended / deleted)
  final bool isActive;

  /// Account creation timestamp (UTC)
  final DateTime createdAt;

  // ---------------------------------------------------------------------------
  // Serialization
  // ---------------------------------------------------------------------------

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: (json['_id'] ?? json['id']) as String? ??
          (throw FormatException('AppUser JSON missing required id field')),
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String? ?? '',
      role: AppUserRole.fromString(json['role'] as String? ?? 'member'),
      avatarUrl: json['avatarUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] is int
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
          : DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.name,
      'avatarUrl': avatarUrl,
      'isActive': isActive,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  // ---------------------------------------------------------------------------
  // Convenience
  // ---------------------------------------------------------------------------

  /// Returns `true` if this user has trainer-level privileges.
  bool get isTrainer => role == AppUserRole.trainer || role == AppUserRole.admin;

  /// First two initials from the name, upper-cased.
  ///
  /// `'Ryan Deniega'` → `'RD'`, `'Ryan'` → `'RY'`
  String get initials => initialsFromName(name);

  /// Extracts two initials from any display name string.
  ///
  /// Shared by [AppUser.initials] and [AppAvatar] so the logic is not
  /// duplicated across the two files.
  static String initialsFromName(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
    }
    final single = parts.first;
    if (single.length >= 2) {
      return single.substring(0, 2).toUpperCase();
    }
    return single.toUpperCase();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUser &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'AppUser(id: $id, name: $name, role: ${role.name})';
}
