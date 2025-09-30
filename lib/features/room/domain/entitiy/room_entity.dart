import 'package:quizduel/features/auth/domain/entity/user_entity.dart';

class RoomEntity {
  final String roomId;
  final String roomName;
  final String hostId;
  final List<UserEntity> user;
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
    required this.user,
    required this.createdAt,
    required this.joinCode,
    required this.maxPlayers,
    required this.quizId,
    required this.isHost,
  });
}