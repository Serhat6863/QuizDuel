import 'package:quizduel/features/auth/data/model/login_user_request.dart';
import 'package:test/test.dart';

void main(){

  group("login user request model", (){

    const userJson = {
      "email" : "test@gmail.com",
      "password" : "password123",
    };


    final loginUserRequestModel = LoginUserRequestDto(
      email: "test@gmail.com",
      password: 'password123',
    );


    test("From json should return a valid model", (){
      final result = LoginUserRequestDto.fromJson(userJson);

      expect(result.email, loginUserRequestModel.email);
      expect(result.password, loginUserRequestModel.password);

    });


    test("To json should return a valid map", (){
      final result = loginUserRequestModel.toJson();

      expect(result, userJson);
    });

  });

}