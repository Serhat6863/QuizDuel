import 'package:quizduel/features/room/domain/entitiy/room_entity.dart';

class RoomModel extends RoomEntity{
  RoomModel({
    required super.roomId,
    required super.roomName,
    required super.hostId,
    required super.userId,
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
      userId: json['userId'] != null ? List<String>.from(json['userId']) : [],
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
      'userId': userId ?? [],
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
      userId: userId,
      status: status,
      joinCode: joinCode,
      createdAt: createdAt,
      maxPlayers: maxPlayers,
      quizId: quizId,
      isHost: isHost,
    );
  }
}