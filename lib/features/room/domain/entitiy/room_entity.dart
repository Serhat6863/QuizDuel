class RoomEntity {
  final String roomId;
  final String roomName;
  final String hostId;
  final List<String> userId;
  final String status;
  final String joinCode;
  final DateTime createdAt;
  final int maxPlayers;
  final String quizId;
  final bool isHost;

  RoomEntity({
    required this.roomName,
    required this.roomId,
    required this.hostId,
    required this.status,
    required this.userId,
    required this.createdAt,
    required this.joinCode,
    required this.maxPlayers,
    required this.quizId,
    required this.isHost,
  });
}