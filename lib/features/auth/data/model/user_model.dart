import 'package:quizduel/features/auth/domain/entity/user_entity.dart';

class UserModel extends UserEntity{

  UserModel({
    required super.id,
    required super.email,
    required super.username,
    required super.isReady,
    required super.score,
    required super.isOnline,
    required super.deviceId
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      isReady: json['isReady'] ?? false,
      score: json['score'] ?? 0,
      isOnline: json['isOnline'] ?? false,
      deviceId: json['deviceId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id ?? '',
      'email': email ?? '',
      'username': username ?? '',
      'isReady': isReady ?? false,
      'score': score ?? 0,
      'isOnline': isOnline ?? false,
      'deviceId': deviceId ?? '',
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      username: username,
      isReady: isReady,
      score: score,
      isOnline: isOnline,
      deviceId: deviceId,
    );
  }
}