import 'package:quizduel/features/auth/data/model/user_model.dart';
import 'package:quizduel/features/game/data/model/quiz_model.dart';
import 'package:quizduel/features/room/domain/entitiy/room_entity.dart';
import 'package:quizduel/features/room/domain/enums/room_game_status.dart';

class RoomModel extends RoomEntity {
  RoomModel({
    required super.roomId,
    required super.roomName,
    required super.hostId,
    required super.user,
    required super.status,
    required super.joinCode,
    required super.createdAt,
    required super.maxPlayers,
    required super.quiz,
  });

  factory RoomModel.fromJson(Map<dynamic, dynamic> json) {
    return RoomModel(
      roomId: json['roomId']?.toString() ?? '',
      roomName: json['roomName']?.toString() ?? 'Room',
      hostId: json['hostId']?.toString() ?? '',
      user: (json['user'] is Map)
          ? (json['user'] as Map).entries.map((entry) {
        return UserModel.fromJson(
          Map<String, dynamic>.from(entry.value as Map),
        );
      }).toList()
          : [],
      status: RoomGameStatusX.fromString(json["status"]?.toString() ?? 'waiting'),
      joinCode: json['joinCode']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      maxPlayers: json['maxPlayers'] is int ? json['maxPlayers'] : 4,

      // ✅ Convertir les quiz stockés en JSON vers QuizModel
      quiz: (json['quiz'] is List)
          ? (json['quiz'] as List)
          .map((q) => QuizModel.fromJson(Map<String, dynamic>.from(q)))
          .toList()
          : [],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'roomName': roomName,
      'hostId': hostId,
      'user': {
        for (var u in user)
          u.id: (u is UserModel
              ? u.toJson()
              : UserModel(
            id: u.id,
            email: u.email,
            username: u.username,
            isReady: u.isReady,
            score: u.score,
          ).toJson())
      },
      'status': status.toShortString(),
      'joinCode': joinCode,
      'createdAt': createdAt.toIso8601String(),
      'maxPlayers': maxPlayers,

      // ✅ Transformer la liste de QuizEntity en JSON pour Firebase
      'quiz': quiz.map((q) {
        if (q is QuizModel) return q.toJson();
        return {
          'category': q.category,
          'difficulty': q.difficulty,
          'question': q.question,
          'options': q.options,
          'correctAnswerIndex': q.correctAnswerIndex,
        };
      }).toList(),
    };
  }

  RoomEntity toEntity() {
    return RoomEntity(
      roomId: roomId,
      roomName: roomName,
      hostId: hostId,
      user: user,
      status: status,
      joinCode: joinCode,
      createdAt: createdAt,
      maxPlayers: maxPlayers,
      quiz: quiz,
    );
  }
}
