import 'package:quizduel/features/auth/data/model/user_model.dart';
import 'package:quizduel/features/room/domain/entitiy/room_entity.dart';

import '../../../auth/domain/entity/user_entity.dart';

class RoomModel extends RoomEntity{
  RoomModel({
    required super.roomId,
    required super.roomName,
    required super.hostId,
    required super.user,
    required super.status,
    required super.joinCode,
    required super.createdAt,
    required super.maxPlayers,
    required super.quizId,
    required super.isHost,
  });


  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      roomId: json['roomId'] ?? '',
      roomName: json['roomName'] ?? 'Room',
      hostId: json['hostId'] ?? '',
      user: json['user'] != null ? List<UserModel>.from(json['user'].map((x) => UserModel.fromJson(x))) : [],
      status: json['status'] ?? 'waiting',
      joinCode: json['joinCode'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      maxPlayers: json['maxPlayers'] ?? 4,
      quizId: json['quizId'] ?? '',
      isHost: json['isHost'] ?? false,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId ?? '',
      'roomName': roomName ?? 'Room',
      'hostId': hostId ?? '',
      'user': user ?? [],
      'status': status ?? 'waiting',
      'joinCode': joinCode ?? '',
      'createdAt': createdAt.toIso8601String() ?? DateTime.now().toIso8601String(),
      'maxPlayers': maxPlayers ?? 4,
      'quizId': quizId ?? '',
      'isHost': isHost ?? false,
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
      quizId: quizId,
      isHost: isHost,
    );
  }
}