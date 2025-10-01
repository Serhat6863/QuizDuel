import '../../../auth/data/model/user_model.dart';
import '../../domain/entitiy/room_entity.dart';

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
    required super.quizId,
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
      status: json['status']?.toString() ?? 'waiting',
      joinCode: json['joinCode']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      maxPlayers: json['maxPlayers'] is int ? json['maxPlayers'] : 4,
      quizId: json['quizId']?.toString() ?? '',
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
          u.id: (u is UserModel ? u.toJson() : UserModel(
            id: u.id,
            email: u.email,
            username: u.username,
          ).toJson())
      },
      'status': status,
      'joinCode': joinCode,
      'createdAt': createdAt.toIso8601String(),
      'maxPlayers': maxPlayers,
      'quizId': quizId,
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
    );
  }
}
