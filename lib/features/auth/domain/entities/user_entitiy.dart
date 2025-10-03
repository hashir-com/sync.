class UserEntity {
  final String uid;
  final String email;
  final String? name;

  const UserEntity({
    required this.uid,
    required this.email,
    this.name,
  });
}