import 'package:flutter_test/flutter_test.dart';
import 'package:quizduel/features/auth/data/model/user_model.dart';
import 'package:quizduel/features/auth/domain/entity/user_entity.dart';

void main() {
  group("UserModel", () {
    final userModel = UserModel(
      id: "123",
      email: "test@example.com",
      username: "Serhat",
      isReady: true,
      score: 42,
    );

    final userJson = {
      "id": "123",
      "email": "test@example.com",
      "username": "Serhat",
      "isReady": true,
      "score": 42,
    };

    test("✅ toJson() retourne la bonne map", () {
      expect(userModel.toJson(), equals(userJson));
    });

    test("✅ fromJson() retourne une instance correcte", () {
      final result = UserModel.fromJson(userJson);
      expect(result.id, equals("123"));
      expect(result.email, equals("test@example.com"));
      expect(result.username, equals("Serhat"));
      expect(result.isReady, isTrue);
      expect(result.score, equals(42));
    });

    test("✅ toEntity() convertit bien en UserEntity", () {
      final entity = userModel.toEntity();
      expect(entity, isA<UserEntity>());
      expect(entity.username, equals("Serhat"));
      expect(entity.score, equals(42));
    });


    test("✅ recrée un UserModel à partir d’un UserEntity manuellement", () {
      final entity = UserEntity(
        id: "abc",
        email: "mail@demo.com",
        username: "Tester",
        isReady: false,
        score: 10,
      );

      final model = UserModel(
        id: entity.id,
        email: entity.email,
        username: entity.username,
        isReady: entity.isReady,
        score: entity.score,
      );

      expect(model.id, equals("abc"));
      expect(model.username, equals("Tester"));
      expect(model.score, equals(10));
    });

    test("✅ fromJson() gère les valeurs null avec valeurs par défaut", () {
      final result = UserModel.fromJson({});
      expect(result.id, equals(''));
      expect(result.email, equals(''));
      expect(result.username, equals(''));
      expect(result.isReady, isFalse);
      expect(result.score, equals(0));
    });
  });
}
