import 'package:quizduel/features/auth/data/model/login_user_request.dart';
import 'package:quizduel/features/auth/data/service/firebase_user_service.dart';
import 'package:quizduel/features/auth/domain/entity/user_entity.dart';
import 'package:quizduel/features/auth/domain/repository/user_repository.dart';

import '../model/register_user_request.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseUserService firebaseUserService;

  UserRepositoryImpl({required this.firebaseUserService});

  @override
  Future<void> signOut() async {
    try {
      await firebaseUserService.signOut();
    } catch (e) {
      throw Exception("Error in UserRepositoryImpl.signOut: $e");
    }
  }



  @override
  Future<UserEntity> signIn(String email, String password) async {
    try {
      final request = LoginUserRequestDto(email: email, password: password);
      final userModel = await firebaseUserService.signInWithEmailAndPassword(
        request.email,
        request.password,
      );

      if (userModel == null) {
        throw Exception("SignIn failed: no user returned from Firebase");
      }

      return userModel.toEntity();
    } catch (e) {
      throw Exception("Error in UserRepositoryImpl.signIn: $e");
    }
  }

  @override
  Future<UserEntity> register(String email, String password, String username) async{
    try{
      final request = RegisterUserRequestDto(email: email, password: password, username: username);

      final userModel = await firebaseUserService.registerWithEmailAndPassword(
        request.email,
        request.username,
        request.password,
      );


      if(userModel == null){
        throw Exception("Register failed: no user returned from Firebase");
      }
      return userModel.toEntity();

    }catch(e){
      throw Exception("Error in UserRepositoryImpl.register: $e");
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async{
    try{
      final userModel = await firebaseUserService.getCurrentUser();

      if(userModel == null){
        return null;
      }

      return userModel.toEntity();

    }catch(e){
      throw Exception("Error in UserRepositoryImpl.getCurrentUser: $e");
    }
  }

  @override
  Future<String> getUsernameById(String userId) async{
    try{
      final username = await firebaseUserService.getUsernameById(userId);
      return username;
    }catch(e){
      throw Exception("Error in UserRepositoryImpl.getUsernameById: $e");
    }
  }

  @override
  Future<List<UserEntity>> getAllUsers() async{
    try{
      final userModels = await firebaseUserService.getAllUser();
      return userModels.map((e) => e.toEntity()).toList();
    }catch(e){
      throw Exception("Error in UserRepositoryImpl.getAllUsers: $e");
    }
  }

  @override
  Future<void> updateScore(String userId, int newScore)  async{
    try{
      await firebaseUserService.updateScore(userId, newScore);
    }catch(e){
      throw Exception("Error in UserRepositoryImpl.updateScore: $e");
    }
  }

  @override
  Future<bool> checkEmailVerified() async{
    try{
      final isVerified = await firebaseUserService.checkEmailVerified();
      return isVerified;
    }catch(e){
      throw Exception("Error in UserRepositoryImpl.checkEmailVerified: $e");
    }
  }

  @override
  Future<void> resentEmailVerification() async{
    try{
      await firebaseUserService.resentEmailVerification();
    }catch(e){
      throw Exception("Error in UserRepositoryImpl.resentEmailVerification: $e");
    }
  }

  @override
  Future<void> deleteAccount() async{
    try{
      await firebaseUserService.deleteAccount();
    }catch(e){
      throw Exception("Error in UserRepositoryImpl.deleteAccount: $e");
    }
  }

  @override
  Future<void> resetPassword(String email) async{
    try{
      await firebaseUserService.resetPassword(email);
    }catch(e){
      throw Exception("Error in UserRepositoryImpl.resetPassword: $e");
    }
  }
}
