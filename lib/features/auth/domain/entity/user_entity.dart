class UserEntity {
  final String id;
  final String email;
  final String username;
  final bool? isReady;
  final int? score;
  final bool isOnline;
  final String deviceId;


  UserEntity({
    required this.id,
    required this.email,
    required this.username,
    required this.isOnline,
    required this.deviceId,
    this.isReady,
    this.score,
  });
}