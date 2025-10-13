class UserEntity {
  final String id;
  final String email;
  final String username;
  final bool? isReady;
  final int? score;


  UserEntity({
    required this.id,
    required this.email,
    required this.username,
    this.isReady,
    this.score,
  });
}