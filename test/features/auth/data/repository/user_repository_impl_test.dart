import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quizduel/core/error/app_failure.dart';
import 'package:quizduel/features/auth/data/model/user_model.dart';
import 'package:quizduel/features/auth/data/service/firebase_user_service.dart';
import 'package:quizduel/features/auth/data/repository/user_repository_impl.dart';
import 'package:quizduel/features/auth/domain/entity/user_entity.dart';

class MockFirebaseUserService extends Mock implements FirebaseUserService {}

void main() {
  late MockFirebaseUserService mockFirebaseUserService;
  late UserRepositoryImpl userRepositoryImpl;

  const testEmail = "test@example.com";
  const testPassword = "password123";
  const testUsername = "Serhat";
  const testUserId = "uid123";

  final fakeUserModel = UserModel(
    id: testUserId,
    email: testEmail,
    username: testUsername,
    isReady: false,
    score: 0,
    isOnline: true,
    deviceId: "device-123",
  );

  setUpAll(() {
    registerFallbackValue(fakeUserModel);
  });

  setUp(() {
    mockFirebaseUserService = MockFirebaseUserService();
    userRepositoryImpl =
        UserRepositoryImpl(firebaseUserService: mockFirebaseUserService);
  });

  group("🧩 UserRepositoryImpl Tests", () {
    test("✅ signIn returns UserEntity when successful", () async {
      when(() => mockFirebaseUserService.signInWithEmailAndPassword(any(), any()))
          .thenAnswer((_) async => fakeUserModel);

      final result = await userRepositoryImpl.signIn(testEmail, testPassword);

      expect(result, isA<UserEntity>());
      expect(result.id, equals(testUserId));
      expect(result.username, equals(testUsername));
      verify(() => mockFirebaseUserService.signInWithEmailAndPassword(testEmail, testPassword)).called(1);
    });

    test("❌ signIn throws AppFailure when userModel is null", () async {
      when(() => mockFirebaseUserService.signInWithEmailAndPassword(any(), any()))
          .thenAnswer((_) async => null);

      expect(
            () => userRepositoryImpl.signIn(testEmail, testPassword),
        throwsA(isA<AppFailure>().having((e) => e.code, 'code', 'null-user')),
      );
    });

    test("✅ register returns UserEntity when successful", () async {
      when(() => mockFirebaseUserService.registerWithEmailAndPassword(any(), any(), any()))
          .thenAnswer((_) async => fakeUserModel);

      final result = await userRepositoryImpl.register(testEmail, testPassword, testUsername);

      expect(result, isA<UserEntity>());
      expect(result.username, equals(testUsername));
      verify(() => mockFirebaseUserService.registerWithEmailAndPassword(
        testEmail,
        testUsername,
        testPassword,
      )).called(1);
    });

    test("❌ register throws AppFailure when userModel is null", () async {
      when(() => mockFirebaseUserService.registerWithEmailAndPassword(any(), any(), any()))
          .thenAnswer((_) async => null);

      expect(
            () => userRepositoryImpl.register(testEmail, testPassword, testUsername),
        throwsA(isA<AppFailure>().having((e) => e.code, 'code', 'null-user')),
      );
    });

    test("✅ getCurrentUser returns UserEntity if found", () async {
      when(() => mockFirebaseUserService.getCurrentUser())
          .thenAnswer((_) async => fakeUserModel);

      final result = await userRepositoryImpl.getCurrentUser();

      expect(result, isA<UserEntity>());
      expect(result?.email, equals(testEmail));
      verify(() => mockFirebaseUserService.getCurrentUser()).called(1);
    });

    test("✅ getCurrentUser returns null if no user found", () async {
      when(() => mockFirebaseUserService.getCurrentUser())
          .thenAnswer((_) async => null);

      final result = await userRepositoryImpl.getCurrentUser();

      expect(result, isNull);
      verify(() => mockFirebaseUserService.getCurrentUser()).called(1);
    });

    test("✅ getUsernameById returns correct username", () async {
      when(() => mockFirebaseUserService.getUsernameById(any()))
          .thenAnswer((_) async => testUsername);

      final result = await userRepositoryImpl.getUsernameById(testUserId);

      expect(result, equals(testUsername));
      verify(() => mockFirebaseUserService.getUsernameById(testUserId)).called(1);
    });

    test("✅ getAllUsers returns list of UserEntity", () async {
      when(() => mockFirebaseUserService.getAllUsers())
          .thenAnswer((_) async => [fakeUserModel]);

      final result = await userRepositoryImpl.getAllUsers();

      expect(result, isA<List<UserEntity>>());
      expect(result.first.username, equals(testUsername));
      verify(() => mockFirebaseUserService.getAllUsers()).called(1);
    });

    test("✅ updateScore calls FirebaseUserService", () async {
      when(() => mockFirebaseUserService.updateScore(any(), any()))
          .thenAnswer((_) async {});

      await userRepositoryImpl.updateScore(testUserId, 99);

      verify(() => mockFirebaseUserService.updateScore(testUserId, 99)).called(1);
    });

    test("✅ signOut calls FirebaseUserService", () async {
      when(() => mockFirebaseUserService.signOut()).thenAnswer((_) async {});

      await userRepositoryImpl.signOut();

      verify(() => mockFirebaseUserService.signOut()).called(1);
    });

    test("❌ Firebase method throws → should wrap in AppFailure", () async {
      when(() => mockFirebaseUserService.signOut())
          .thenThrow(Exception("Firebase error"));

      expect(
            () => userRepositoryImpl.signOut(),
        throwsA(isA<AppFailure>()
            .having((f) => f.message, 'message', contains('Error during signOut'))),
      );
    });
  });
}
