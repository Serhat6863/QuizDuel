import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quizduel/core/error/app_failure.dart';
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
  setUpAll(() {
    registerFallbackValue(FakeRoomModel());
    registerFallbackValue(FakeUserModel());
  });

  group("🧩 RoomRepositoryImpl Tests", () {
    late MockFirebaseRoomService mockService;
    late RoomRepositoryImpl repository;
    late UserEntity mockUser;
    late RoomEntity mockRoomEntity;
    late RoomModel mockRoomModel;

    setUp(() {
      mockService = MockFirebaseRoomService();
      repository = RoomRepositoryImpl(firebaseRoomService: mockService);

      mockUser = UserEntity(
        id: "u1",
        email: "test@example.com",
        username: "Serhat",
        isReady: false,
        score: 10,
        isOnline: true,
        deviceId: "device123",
      );

      final userModel = UserModel(
        id: mockUser.id,
        email: mockUser.email,
        username: mockUser.username,
        isReady: mockUser.isReady,
        score: mockUser.score,
        isOnline: mockUser.isOnline,
        deviceId: mockUser.deviceId,
      );

      mockRoomModel = RoomModel(
        roomId: "r1",
        roomName: "Room Test",
        hostId: "u1",
        user: [userModel],
        status: RoomGameStatus.waiting,
        joinCode: "ABCD",
        createdAt: DateTime.parse("2024-01-01T12:00:00Z"),
        maxPlayers: 4,
        quiz: const [],
      );

      mockRoomEntity = mockRoomModel.toEntity();
    });

    // ----------------------------------------------------------------------
    // ✅ CREATE ROOM
    // ----------------------------------------------------------------------
    test("✅ createRoom retourne un RoomEntity en cas de succès", () async {
      when(() => mockService.createRoom(any()))
          .thenAnswer((_) async => mockRoomModel);

      final result = await repository.createRoom(mockRoomEntity);

      expect(result, isA<RoomEntity>());
      expect(result?.roomId, "r1");
      verify(() => mockService.createRoom(any())).called(1);
    });

    test("❌ createRoom lance AppFailure quand Firebase renvoie null", () async {
      when(() => mockService.createRoom(any()))
          .thenAnswer((_) async => null);

      expect(
            () => repository.createRoom(mockRoomEntity),
        throwsA(isA<AppFailure>().having((f) => f.code, "code", "null-room")),
      );
    });

    test("❌ createRoom lance AppFailure quand le service plante", () async {
      when(() => mockService.createRoom(any()))
          .thenThrow(Exception("Firebase create error"));

      expect(
            () => repository.createRoom(mockRoomEntity),
        throwsA(isA<AppFailure>()),
      );
    });

    // ----------------------------------------------------------------------
    // ✅ DELETE ROOM
    // ----------------------------------------------------------------------
    test("✅ deleteRoom appelle deleteRoom du service", () async {
      when(() => mockService.deleteRoom("r1"))
          .thenAnswer((_) async => Future.value());

      await repository.deleteRoom("r1");

      verify(() => mockService.deleteRoom("r1")).called(1);
    });

    test("❌ deleteRoom lance AppFailure en cas d'erreur", () async {
      when(() => mockService.deleteRoom("r1"))
          .thenThrow(Exception("Delete failed"));

      expect(
            () => repository.deleteRoom("r1"),
        throwsA(isA<AppFailure>()),
      );
    });

    // ----------------------------------------------------------------------
    // ✅ GET AVAILABLE ROOMS
    // ----------------------------------------------------------------------
    test("✅ getAvailableRooms retourne une liste de RoomEntity", () async {
      when(() => mockService.getAvailableRooms())
          .thenAnswer((_) async => [mockRoomModel]);

      final result = await repository.getAvailableRooms();

      expect(result, isA<List<RoomEntity>>());
      expect(result.first.roomId, "r1");
    });

    test("❌ getAvailableRooms lance AppFailure en cas d'erreur", () async {
      when(() => mockService.getAvailableRooms())
          .thenThrow(Exception("Fetch failed"));

      expect(() => repository.getAvailableRooms(), throwsA(isA<AppFailure>()));
    });

    // ----------------------------------------------------------------------
    // ✅ JOIN ROOM
    // ----------------------------------------------------------------------
    test("✅ joinRoom appelle joinRoom du service", () async {
      when(() => mockService.joinRoom("r1", any()))
          .thenAnswer((_) async => Future.value());

      await repository.joinRoom("r1", mockUser);
      verify(() => mockService.joinRoom("r1", any())).called(1);
    });

    test("❌ joinRoom lance AppFailure en cas d'erreur", () async {
      when(() => mockService.joinRoom("r1", any()))
          .thenThrow(Exception("Join failed"));

      expect(() => repository.joinRoom("r1", mockUser), throwsA(isA<AppFailure>()));
    });

    // ----------------------------------------------------------------------
    // ✅ LEAVE ROOM
    // ----------------------------------------------------------------------
    test("✅ leaveRoom appelle leaveRoom du service", () async {
      when(() => mockService.leaveRoom("r1", any()))
          .thenAnswer((_) async => Future.value());

      await repository.leaveRoom("r1", mockUser);
      verify(() => mockService.leaveRoom("r1", any())).called(1);
    });

    test("❌ leaveRoom lance AppFailure en cas d'erreur", () async {
      when(() => mockService.leaveRoom("r1", any()))
          .thenThrow(Exception("Leave failed"));

      expect(() => repository.leaveRoom("r1", mockUser), throwsA(isA<AppFailure>()));
    });

    // ----------------------------------------------------------------------
    // ✅ AUTO DELETE
    // ----------------------------------------------------------------------
    test("✅ autoDeleteRoom appelle setAutoDeleteOnDisconnect", () async {
      when(() => mockService.setAutoDeleteOnDisconnect("r1"))
          .thenAnswer((_) async => Future.value());

      await repository.autoDeleteRoom("r1");
      verify(() => mockService.setAutoDeleteOnDisconnect("r1")).called(1);
    });

    test("❌ autoDeleteRoom lance AppFailure en cas d'erreur", () async {
      when(() => mockService.setAutoDeleteOnDisconnect("r1"))
          .thenThrow(Exception("Auto delete failed"));

      expect(() => repository.autoDeleteRoom("r1"), throwsA(isA<AppFailure>()));
    });

    // ----------------------------------------------------------------------
    // ✅ STREAMS
    // ----------------------------------------------------------------------
    test("✅ playersStream renvoie un Stream<List<UserEntity>>", () async {
      when(() => mockService.playerListStream("r1"))
          .thenAnswer((_) => Stream.value([UserModel(
        id: "u1",
        email: "test@example.com",
        username: "Serhat",
        isReady: true,
        score: 10,
        isOnline: true,
        deviceId: "123",
      )]));

      final result = await repository.playersStream("r1").first;
      expect(result.first.username, "Serhat");
    });

    test("✅ roomStatusStream renvoie un Stream<RoomGameStatus>", () async {
      when(() => mockService.roomStatusStream("r1"))
          .thenAnswer((_) => Stream.value(RoomGameStatus.playing));

      final result = await repository.roomStatusStream("r1").first;
      expect(result, equals(RoomGameStatus.playing));
    });

    // ----------------------------------------------------------------------
    // ✅ START GAME
    // ----------------------------------------------------------------------
    test("✅ startGame appelle startGame du service", () async {
      when(() => mockService.startGame("r1"))
          .thenAnswer((_) async => Future.value());

      await repository.startGame("r1");
      verify(() => mockService.startGame("r1")).called(1);
    });

    test("❌ startGame lance AppFailure en cas d'erreur", () async {
      when(() => mockService.startGame("r1"))
          .thenThrow(Exception("Start failed"));

      expect(() => repository.startGame("r1"), throwsA(isA<AppFailure>()));
    });

    // ----------------------------------------------------------------------
    // ✅ UPDATE SCORE
    // ----------------------------------------------------------------------
    test("✅ updateRoomScore appelle updateRoomScore du service", () async {
      when(() => mockService.updateRoomScore("r1", "u1", 50))
          .thenAnswer((_) async => Future.value());

      await repository.updateRoomScore("r1", "u1", 50);
      verify(() => mockService.updateRoomScore("r1", "u1", 50)).called(1);
    });

    test("❌ updateRoomScore lance AppFailure en cas d'erreur", () async {
      when(() => mockService.updateRoomScore("r1", "u1", 50))
          .thenThrow(Exception("Score update failed"));

      expect(() => repository.updateRoomScore("r1", "u1", 50), throwsA(isA<AppFailure>()));
    });

    // ----------------------------------------------------------------------
    // ✅ GET ROOM BY ID
    // ----------------------------------------------------------------------
    test("✅ getRoomById retourne RoomEntity", () async {
      when(() => mockService.getRoomById("r1"))
          .thenAnswer((_) async => mockRoomModel);

      final result = await repository.getRoomById("r1");
      expect(result.roomId, "r1");
    });

    test("❌ getRoomById lance AppFailure en cas d'erreur", () async {
      when(() => mockService.getRoomById("r1"))
          .thenThrow(Exception("Not found"));

      expect(() => repository.getRoomById("r1"), throwsA(isA<AppFailure>()));
    });
  });
}
