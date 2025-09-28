import 'package:quizduel/features/auth/domain/entity/user_entity.dart';

abstract class UserRepository {
  Future<UserEntity> signIn(String email, String password);
  Future<UserEntity> register(String email, String password , String username);
  Future<void> signOut();
  Future<UserEntity?> getCurrentUser();
  Future<String> getUsernameById(String userId);
}