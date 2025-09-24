

import 'package:quizduel/features/auth/data/model/register_user_request.dart';
import 'package:test/test.dart';

void main(){
  group("Register Request", (){
    const RegisterJson = {
      'email' : 'test@gmail.com',
      'username' : 'testuser',
      'password' : 'password123',
    };



    final registerRequetsUserModel = RegisterUserRequestDto(
      email: 'test@gmail.com',
      username: 'testuser',
      password: 'password123',
    );


    test("From json should return a valid model", (){
      final result = RegisterUserRequestDto.fromJson(RegisterJson);

      expect(result.email, registerRequetsUserModel.email);
      expect(result.username, registerRequetsUserModel.username);
      expect(result.password, registerRequetsUserModel.password);

    });

    test("To json should return a valid map", (){
      final result = registerRequetsUserModel.toJson();

      expect(result, RegisterJson);
    });

  });
}