import 'package:flutter_test/flutter_test.dart';
import 'package:quizduel/features/auth/data/model/register_user_request.dart';

void main() {
  group("RegisterUserRequestDto", () {
    const email = "test@example.com";
    const username = "Serhat";
    const password = "123456";

    final dto = RegisterUserRequestDto(
      email: email,
      username: username,
      password: password,
    );

    final dtoJson = {
      "email": email,
      "password": password,
      "username": username,
    };

    test("✅ toJson() retourne la bonne map", () {
      expect(dto.toJson(), equals(dtoJson));
    });

    test("✅ fromJson() crée une instance correcte", () {
      final result = RegisterUserRequestDto.fromJson(dtoJson);
      expect(result.email, equals(email));
      expect(result.username, equals(username));
      expect(result.password, equals(password));
    });

    test("✅ fromJson() gère les champs manquants avec valeurs par défaut", () {
      final result = RegisterUserRequestDto.fromJson({});
      expect(result.email, equals(''));
      expect(result.username, equals(''));
      expect(result.password, equals(''));
    });
  });
}
