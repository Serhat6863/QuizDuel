import 'package:quizduel/core/error/app_failure.dart';
import 'package:quizduel/features/auth/data/model/login_user_request.dart';
import 'package:quizduel/features/auth/data/model/register_user_request.dart';
import 'package:quizduel/features/auth/data/service/firebase_user_service.dart';
import 'package:quizduel/features/auth/domain/entity/user_entity.dart';
import 'package:quizduel/features/auth/domain/repository/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseUserService firebaseUserService;

  UserRepositoryImpl({required this.firebaseUserService});

  @override
  Future<void> signOut() async {
    try {
      await firebaseUserService.signOut();
    } catch (e) {
      throw AppFailure(
        message: "Error during signOut: ${_extractMessage(e)}",
        code: _extractCode(e),
      );
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
        throw AppFailure(message: "SignIn failed: no user returned from Firebase", code: "null-user");
      }

      return userModel.toEntity();
    } catch (e) {
      throw AppFailure(
        message: "Error in signIn: ${_extractMessage(e)}",
        code: _extractCode(e),
      );
    }
  }

  @override
  Future<UserEntity> register(String email, String password, String username) async {
    try {
      final request = RegisterUserRequestDto(
        email: email,
        password: password,
        username: username,
      );

      final userModel = await firebaseUserService.registerWithEmailAndPassword(
        request.email,
        request.username,
        request.password,
      );

      if (userModel == null) {
        throw AppFailure(message: "Register failed: no user returned from Firebase", code: "null-user");
      }

      return userModel.toEntity();
    } catch (e) {
      throw AppFailure(
        message: "Error in register: ${_extractMessage(e)}",
        code: _extractCode(e),
      );
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final userModel = await firebaseUserService.getCurrentUser();
      return userModel?.toEntity();
    } catch (e) {
      throw AppFailure(
        message: "Error in getCurrentUser: ${_extractMessage(e)}",
        code: _extractCode(e),
      );
    }
  }

  @override
  Future<String> getUsernameById(String userId) async {
    try {
      return await firebaseUserService.getUsernameById(userId);
    } catch (e) {
      throw AppFailure(
        message: "Error in getUsernameById: ${_extractMessage(e)}",
        code: _extractCode(e),
      );
    }
  }

  @override
  Future<List<UserEntity>> getAllUsers() async {
    try {
      final userModels = await firebaseUserService.getAllUsers();
      return userModels.map((e) => e.toEntity()).toList();
    } catch (e) {
      throw AppFailure(
        message: "Error in getAllUsers: ${_extractMessage(e)}",
        code: _extractCode(e),
      );
    }
  }

  @override
  Future<void> updateScore(String userId, int newScore) async {
    try {
      await firebaseUserService.updateScore(userId, newScore);
    } catch (e) {
      throw AppFailure(
        message: "Error in updateScore: ${_extractMessage(e)}",
        code: _extractCode(e),
      );
    }
  }

  @override
  Future<bool> checkEmailVerified() async {
    try {
      return await firebaseUserService.checkEmailVerified();
    } catch (e) {
      throw AppFailure(
        message: "Error in checkEmailVerified: ${_extractMessage(e)}",
        code: _extractCode(e),
      );
    }
  }

  @override
  Future<void> resentEmailVerification() async {
    try {
      await firebaseUserService.resentEmailVerification();
    } catch (e) {
      throw AppFailure(
        message: "Error in resentEmailVerification: ${_extractMessage(e)}",
        code: _extractCode(e),
      );
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await firebaseUserService.deleteAccount();
    } catch (e) {
      throw AppFailure(
        message: "Error in deleteAccount: ${_extractMessage(e)}",
        code: _extractCode(e),
      );
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await firebaseUserService.resetPassword(email);
    } catch (e) {
      throw AppFailure(
        message: "Error in resetPassword: ${_extractMessage(e)}",
        code: _extractCode(e),
      );
    }
  }

  // 🔹 Helpers pour éviter la répétition
  String _extractMessage(Object e) {
    if (e is AppFailure) return e.message;
    return e.toString();
  }

  String _extractCode(Object e) {
    if (e is AppFailure) return e.code;
    return 'unknown';
  }
}
