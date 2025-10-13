import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quizduel/features/auth/data/model/user_model.dart';
import 'package:quizduel/features/auth/domain/entity/user_entity.dart';
import 'package:quizduel/features/room/data/model/room_model.dart';
import 'package:quizduel/features/room/data/repository/room_repository_impl.dart';
import 'package:quizduel/features/room/data/service/firebase_room_service.dart';
import 'package:quizduel/features/room/domain/entitiy/room_entity.dart';
import 'package:quizduel/features/room/domain/enums/room_game_status.dart';

/// ✅ Fakes pour Mocktail (obligatoires pour any() sur classes custom)
class FakeRoomModel extends Fake implements RoomModel {}
class FakeUserModel extends Fake implements UserModel {}

class MockFirebaseRoomService extends Mock implements FirebaseRoomService {}

void main() {
  /// ✅ On enregistre les fallback values avant tous les tests
  setUpAll(() {
    registerFallbackValue(FakeRoomModel());
    registerFallbackValue(FakeUserModel());
  });

  group("RoomRepositoryImpl", () {
    late MockFirebaseRoomService mockService;
    late RoomRepositoryImpl repository;
    late UserEntity mockUser;
    late UserModel mockUserModel;
    late RoomModel mockRoomModel;
    late RoomEntity mockRoomEntity;

    setUp(() {
      mockService = MockFirebaseRoomService();
      repository = RoomRepositoryImpl(firebaseRoomService: mockService);

      mockUser = UserEntity(
        id: "u1",
        email: "test@example.com",
        username: "Serhat",
        isReady: false,
        score: 10,
      );

      mockUserModel = UserModel(
        id: mockUser.id,
        email: mockUser.email,
        username: mockUser.username,
        isReady: mockUser.isReady,
        score: mockUser.score,
      );

      mockRoomModel = RoomModel(
        roomId: "r1",
        roomName: "Room Test",
        hostId: "u1",
        user: [mockUserModel],
        status: RoomGameStatus.waiting,
        joinCode: "ABCD",
        createdAt: DateTime.parse("2024-01-01T12:00:00Z"),
        maxPlayers: 4,
        quiz: const [],
      );

      mockRoomEntity = mockRoomModel.toEntity();
    });

    // ✅ CREATE ROOM
    test("createRoom retourne RoomEntity quand la création réussit", () async {
      when(() => mockService.createRoom(any()))
          .thenAnswer((_) async => mockRoomModel);

      final result = await repository.createRoom(mockRoomEntity);

      expect(result, isA<RoomEntity>());
      expect(result?.roomId, "r1");
      verify(() => mockService.createRoom(any(that: isA<RoomModel>()))).called(1);
    });

    test("createRoom lance une exception si le service échoue", () async {
      when(() => mockService.createRoom(any()))
          .thenThrow(Exception("Firebase create error"));

      expect(
            () => repository.createRoom(mockRoomEntity),
        throwsA(isA<Exception>()),
      );
      verify(() => mockService.createRoom(any())).called(1);
    });

    // ✅ DELETE ROOM
    test("deleteRoom appelle firebaseRoomService.deleteRoom", () async {
      when(() => mockService.deleteRoom("r1"))
          .thenAnswer((_) async => Future.value());

      await repository.deleteRoom("r1");
      verify(() => mockService.deleteRoom("r1")).called(1);
    });

    test("deleteRoom lance une exception en cas d'erreur", () async {
      when(() => mockService.deleteRoom("r1"))
          .thenThrow(Exception("Delete failed"));

      expect(() => repository.deleteRoom("r1"), throwsA(isA<Exception>()));
    });

    // ✅ GET AVAILABLE ROOMS
    test("getAvailableRooms retourne une liste de RoomEntity", () async {
      when(() => mockService.getAvailableRooms())
          .thenAnswer((_) async => [mockRoomModel]);

      final result = await repository.getAvailableRooms();

      expect(result, isA<List<RoomEntity>>());
      expect(result.first.roomId, "r1");
      verify(() => mockService.getAvailableRooms()).called(1);
    });

    test("getAvailableRooms lance une exception si erreur", () async {
      when(() => mockService.getAvailableRooms())
          .thenThrow(Exception("Failed"));

      expect(() => repository.getAvailableRooms(), throwsA(isA<Exception>()));
    });

    // ✅ JOIN ROOM
    test("joinRoom appelle firebaseRoomService.joinRoom", () async {
      when(() => mockService.joinRoom("r1", any()))
          .thenAnswer((_) async => Future.value());

      await repository.joinRoom("r1", mockUser);
      verify(() => mockService.joinRoom(
        "r1",
        any(that: isA<UserModel>()),
      )).called(1);
    });

    test("joinRoom lance une exception en cas d'erreur", () async {
      when(() => mockService.joinRoom("r1", any()))
          .thenThrow(Exception("Join failed"));

      expect(() => repository.joinRoom("r1", mockUser), throwsA(isA<Exception>()));
    });

    // ✅ LEAVE ROOM
    test("leaveRoom appelle firebaseRoomService.leaveRoom", () async {
      when(() => mockService.leaveRoom("r1", any()))
          .thenAnswer((_) async => Future.value());

      await repository.leaveRoom("r1", mockUser);
      verify(() => mockService.leaveRoom(
        "r1",
        any(that: isA<UserModel>()),
      )).called(1);
    });

    test("leaveRoom lance une exception en cas d'erreur", () async {
      when(() => mockService.leaveRoom("r1", any()))
          .thenThrow(Exception("Leave failed"));

      expect(() => repository.leaveRoom("r1", mockUser), throwsA(isA<Exception>()));
    });

    // ✅ AUTO DELETE
    test("autoDeleteRoom appelle setAutoDeleteOnDisconnect", () async {
      when(() => mockService.setAutoDeleteOnDisconnect("r1"))
          .thenAnswer((_) async => Future.value());

      await repository.autoDeleteRoom("r1");
      verify(() => mockService.setAutoDeleteOnDisconnect("r1")).called(1);
    });

    // ✅ PLAYERS STREAM
    test("playersStream renvoie un stream de UserEntity", () async {
      when(() => mockService.playerListStream("r1"))
          .thenAnswer((_) => Stream.value([mockUserModel]));

      final result = await repository.playersStream("r1").first;

      expect(result.first.username, "Serhat");
      verify(() => mockService.playerListStream("r1")).called(1);
    });

    // ✅ ROOM STATUS STREAM
    test("roomStatusStream renvoie un stream de RoomGameStatus", () async {
      when(() => mockService.roomStatusStream("r1"))
          .thenAnswer((_) => Stream.value(RoomGameStatus.playing));

      final result = await repository.roomStatusStream("r1").first;
      expect(result, RoomGameStatus.playing);
      verify(() => mockService.roomStatusStream("r1")).called(1);
    });

    // ✅ START GAME
    test("startGame appelle firebaseRoomService.startGame", () async {
      when(() => mockService.startGame("r1"))
          .thenAnswer((_) async => Future.value());

      await repository.startGame("r1");
      verify(() => mockService.startGame("r1")).called(1);
    });

    // ✅ UPDATE SCORE
    test("updateRoomScore appelle firebaseRoomService.updateRoomScore", () async {
      when(() => mockService.updateRoomScore("r1", "u1", 50))
          .thenAnswer((_) async => Future.value());

      await repository.updateRoomScore("r1", "u1", 50);
      verify(() => mockService.updateRoomScore("r1", "u1", 50)).called(1);
    });

    // ✅ GET ROOM BY ID
    test("getRoomById retourne RoomEntity si trouvée", () async {
      when(() => mockService.getRoomById("r1"))
          .thenAnswer((_) async => mockRoomModel);

      final result = await repository.getRoomById("r1");
      expect(result.roomId, "r1");
      verify(() => mockService.getRoomById("r1")).called(1);
    });

    test("getRoomById lance une exception si aucune room trouvée", () async {
      when(() => mockService.getRoomById("r1"))
          .thenThrow(Exception("No room found"));

      expect(() => repository.getRoomById("r1"), throwsA(isA<Exception>()));
      verify(() => mockService.getRoomById("r1")).called(1);
    });
  });
}
