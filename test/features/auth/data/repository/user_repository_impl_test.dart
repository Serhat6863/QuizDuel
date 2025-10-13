import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
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
    score: 10,
    isReady: null,

  );

  final fakeUserEntity = fakeUserModel.toEntity();

  setUp(() {
    mockFirebaseUserService = MockFirebaseUserService();
    userRepositoryImpl = UserRepositoryImpl(firebaseUserService: mockFirebaseUserService);
  });

  group("UserRepositoryImpl", () {
    test("✅ signIn retourne UserEntity en cas de succès", () async {
      // Arrange
      when(() => mockFirebaseUserService.signInWithEmailAndPassword(
        any(),
        any(),
      )).thenAnswer((_) async => fakeUserModel);

      // Act
      final result = await userRepositoryImpl.signIn(testEmail, testPassword);

      // Assert
      expect(result, isA<UserEntity>());
      expect(result.id, equals(testUserId));
      expect(result.username, equals(testUsername));

      verify(() => mockFirebaseUserService.signInWithEmailAndPassword(testEmail, testPassword)).called(1);
    });

    test("❌ signIn lance une exception si userModel est null", () async {
      when(() => mockFirebaseUserService.signInWithEmailAndPassword(any(), any()))
          .thenAnswer((_) async => null);

      expect(() => userRepositoryImpl.signIn(testEmail, testPassword), throwsA(isA<Exception>()));
    });

    test("✅ register retourne UserEntity en cas de succès", () async {
      when(() => mockFirebaseUserService.registerWithEmailAndPassword(
        any(),
        any(),
        any(),
      )).thenAnswer((_) async => fakeUserModel);

      final result = await userRepositoryImpl.register(testEmail, testPassword, testUsername);

      expect(result, isA<UserEntity>());
      expect(result.username, equals(testUsername));

      verify(() => mockFirebaseUserService.registerWithEmailAndPassword(testEmail, testUsername, testPassword))
          .called(1);
    });

    test("❌ register lance une exception si userModel est null", () async {
      when(() => mockFirebaseUserService.registerWithEmailAndPassword(any(), any(), any()))
          .thenAnswer((_) async => null);

      expect(() => userRepositoryImpl.register(testEmail, testPassword, testUsername), throwsA(isA<Exception>()));
    });

    test("✅ getCurrentUser retourne UserEntity si trouvé", () async {
      when(() => mockFirebaseUserService.getCurrentUser()).thenAnswer((_) async => fakeUserModel);

      final result = await userRepositoryImpl.getCurrentUser();

      expect(result, isA<UserEntity>());
      expect(result?.email, equals(testEmail));

      verify(() => mockFirebaseUserService.getCurrentUser()).called(1);
    });

    test("✅ getCurrentUser retourne null si aucun utilisateur", () async {
      when(() => mockFirebaseUserService.getCurrentUser()).thenAnswer((_) async => null);

      final result = await userRepositoryImpl.getCurrentUser();

      expect(result, isNull);
      verify(() => mockFirebaseUserService.getCurrentUser()).called(1);
    });

    test("✅ getUsernameById retourne le bon username", () async {
      when(() => mockFirebaseUserService.getUsernameById(any())).thenAnswer((_) async => testUsername);

      final result = await userRepositoryImpl.getUsernameById(testUserId);

      expect(result, equals(testUsername));
      verify(() => mockFirebaseUserService.getUsernameById(testUserId)).called(1);
    });

    test("✅ getAllUsers retourne une liste de UserEntity", () async {
      when(() => mockFirebaseUserService.getAllUser()).thenAnswer((_) async => [fakeUserModel]);

      final result = await userRepositoryImpl.getAllUsers();

      expect(result, isA<List<UserEntity>>());
      expect(result.first.username, equals(testUsername));

      verify(() => mockFirebaseUserService.getAllUser()).called(1);
    });

    test("✅ updateScore appelle bien le service Firebase", () async {
      when(() => mockFirebaseUserService.updateScore(any(), any())).thenAnswer((_) async {});

      await userRepositoryImpl.updateScore(testUserId, 100);

      verify(() => mockFirebaseUserService.updateScore(testUserId, 100)).called(1);
    });

    test("✅ signOut appelle bien le service Firebase", () async {
      when(() => mockFirebaseUserService.signOut()).thenAnswer((_) async {});

      await userRepositoryImpl.signOut();

      verify(() => mockFirebaseUserService.signOut()).called(1);
    });
  });
}
