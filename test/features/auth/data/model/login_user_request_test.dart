import 'package:flutter_test/flutter_test.dart';
import 'package:quizduel/features/auth/data/model/login_user_request.dart';

void main() {
  group("LoginUserRequestDto", () {
    const email = "test@example.com";
    const password = "mypassword";

    final dto = LoginUserRequestDto(email: email, password: password);

    final dtoJson = {
      "email": email,
      "password": password,
    };

    test("✅ toJson() retourne la bonne map", () {
      expect(dto.toJson(), equals(dtoJson));
    });

    test("✅ fromJson() crée une instance correcte", () {
      final result = LoginUserRequestDto.fromJson(dtoJson);
      expect(result.email, equals(email));
      expect(result.password, equals(password));
    });

    test("✅ fromJson() gère les champs manquants avec valeurs par défaut", () {
      final result = LoginUserRequestDto.fromJson({});
      expect(result.email, equals(''));
      expect(result.password, equals(''));
    });
  });
}
