import 'package:quizduel/features/auth/data/service/firebase_user_service.dart';
import 'package:quizduel/features/auth/domain/repository/user_repository.dart';

class UserRepositoryImpl implements UserRepository {

  final FirebaseUserService firebaseUserService;

  UserRepositoryImpl({required this.firebaseUserService});

  @override
  Future<void> register(String email, String password) async{
    try{
      await firebaseUserService.registerWithEmailAndPassword(email, password);
    }catch(e){
      print("Error in UserRepositoryImpl register: $e");
    }
  }

  @override
  Future<void> signIn(String email, String password) async{
    try{
      await firebaseUserService.signInWithEmailAndPassword(email, password);
    }catch(e){
      print("Error in UserRepositoryImpl signIn: $e");
    }
  }

  @override
  Future<void> signOut() async{
    try{
      await firebaseUserService.signOut();
    }catch(e){
      print("Error in UserRepositoryImpl signOut: $e");
    }
  }

}