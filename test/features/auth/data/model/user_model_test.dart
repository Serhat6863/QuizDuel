import 'package:flutter_test/flutter_test.dart';
import 'package:quizduel/features/auth/data/model/user_model.dart';
import 'package:quizduel/features/auth/domain/entity/user_entity.dart';

void main() {
  group('🧩 UserModel Tests', () {
    final userModel = UserModel(
      id: "123",
      email: "test@example.com",
      username: "Serhat",
      isReady: true,
      score: 42,
      isOnline: true,
      deviceId: "device123",
    );

    final userJson = {
      "id": "123",
      "email": "test@example.com",
      "username": "Serhat",
      "isReady": true,
      "score": 42,
      "isOnline": true,
      "deviceId": "device123",
    };

    test("✅ toJson() returns the correct map", () {
      expect(userModel.toJson(), equals(userJson));
    });

    test("✅ fromJson() returns a correct instance", () {
      final result = UserModel.fromJson(userJson);
      expect(result.id, equals("123"));
      expect(result.email, equals("test@example.com"));
      expect(result.username, equals("Serhat"));
      expect(result.isReady, isTrue);
      expect(result.score, equals(42));
      expect(result.isOnline, isTrue);
      expect(result.deviceId, equals("device123"));
    });

    test("✅ toEntity() correctly converts to UserEntity", () {
      final entity = userModel.toEntity();
      expect(entity, isA<UserEntity>());
      expect(entity.username, equals("Serhat"));
      expect(entity.isOnline, isTrue);
      expect(entity.deviceId, equals("device123"));
    });

    test("✅ can recreate UserModel from a UserEntity", () {
      final entity = UserEntity(
        id: "abc",
        email: "demo@mail.com",
        username: "Tester",
        isReady: false,
        score: 10,
        isOnline: false,
        deviceId: "dev999",
      );

      final model = UserModel(
        id: entity.id,
        email: entity.email,
        username: entity.username,
        isReady: entity.isReady,
        score: entity.score,
        isOnline: entity.isOnline,
        deviceId: entity.deviceId,
      );

      expect(model.id, equals("abc"));
      expect(model.username, equals("Tester"));
      expect(model.isOnline, isFalse);
      expect(model.deviceId, equals("dev999"));
    });

    test("✅ fromJson() handles missing fields with default values", () {
      final result = UserModel.fromJson({});
      expect(result.id, equals(''));
      expect(result.email, equals(''));
      expect(result.username, equals(''));
      expect(result.isReady, isFalse);
      expect(result.score, equals(0));
      expect(result.isOnline, isFalse);
      expect(result.deviceId, equals(''));
    });
  });
}
