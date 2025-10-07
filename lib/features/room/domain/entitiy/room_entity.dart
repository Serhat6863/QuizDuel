import 'package:quizduel/features/auth/domain/entity/user_entity.dart';
import 'package:quizduel/features/game/domain/entity/quiz_entity.dart';
import 'package:quizduel/features/room/domain/enums/room_game_status.dart';

class RoomEntity {
  final String roomId;
  final String roomName;
  final String hostId;
  final List<UserEntity> user;
  final RoomGameStatus status;
  final String joinCode;
  final DateTime createdAt;
  final int maxPlayers;
  final List<QuizEntity> quiz;

  RoomEntity({
    required this.roomName,
    required this.roomId,
    required this.hostId,
    required this.status,
    required this.user,
    required this.createdAt,
    required this.joinCode,
    required this.maxPlayers,
    required this.quiz,
  });
}