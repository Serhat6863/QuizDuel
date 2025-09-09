import 'package:test/test.dart';
import 'package:quizduel/features/auth/data/model/user_model.dart';


void main(){
  group("UserModel", (){
    const userJson = {
      'id' : '123',
      'email' : 'test@gmail.com',
      'username' : 'testuser',
    };


    final userModel = UserModel(
      id: '123',
      email: 'test@gmail.com',
      username: 'testuser',
    );
    
    test("From json should return a valid user Model", (){
      final result = UserModel.fromJson(userJson);

      expect(result.id, userModel.id);
      expect(result.email, userModel.email);
      expect(result.username, userModel.username);

    });


    test("To json should return a valid map", (){
      final result = userModel.toJson();

      expect(result, userJson);
    });
    
  });
}