abstract interface class ProfileRepository {
  Future<void> deleteAccount();
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? avatarUrl,
    String? goal,
    int? height,
    int? weight,
    int? age,
    String? gender,
  });
}
