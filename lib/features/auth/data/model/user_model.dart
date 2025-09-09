import 'package:quizduel/features/auth/domain/entity/user_entity.dart';

class UserModel extends UserEntity{

  UserModel({
    required super.id,
    required super.email,
    required super.username,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
    };
  }
}