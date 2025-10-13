import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:quizduel/features/auth/domain/entity/user_entity.dart';
import 'package:quizduel/features/auth/domain/repository/user_repository.dart';
import 'package:quizduel/features/room/domain/entitiy/room_entity.dart';
import 'package:quizduel/features/room/domain/enums/room_game_status.dart';
import 'package:quizduel/features/room/domain/repository/room_repository.dart';

import 'package:quizduel/features/room/presentation/bloc/room_bloc.dart';
import 'package:quizduel/features/room/presentation/bloc/room_event.dart';
import 'package:quizduel/features/room/presentation/bloc/room_state.dart';

// Mocks
class MockRoomRepository extends Mock implements RoomRepository {}
class MockUserRepository extends Mock implements UserRepository {}

// Fakes pour registerFallbackValue
class FakeRoomEntity extends Fake implements RoomEntity {}
class FakeUserEntity extends Fake implements UserEntity {}

void main() {
  late MockRoomRepository roomRepo;
  late MockUserRepository userRepo;
  late RoomBloc bloc;

  // valeurs réutilisables
  final user = UserEntity(
    id: 'u1',
    email: 'u1@test.com',
    username: 'Serhat',
    isReady: false,
    score: 0,
  );

  final room = RoomEntity(
    roomId: 'r1',
    roomName: 'Test Room',
    hostId: 'u1',
    user: <UserEntity>[],
    status: RoomGameStatus.waiting,
    joinCode: 'ABC123',
    createdAt: DateTime(2025, 1, 1),
    maxPlayers: 4,
    quiz: const [],
  );

  setUpAll(() {
    registerFallbackValue(FakeRoomEntity());
    registerFallbackValue(FakeUserEntity());
  });

  setUp(() {
    roomRepo = MockRoomRepository();
    userRepo = MockUserRepository();

    // Évite l’erreur "type 'Null' is not a subtype of Stream<List<UserEntity>>"
    when(() => roomRepo.playersStream(any())).thenAnswer((_) => const Stream.empty());
    // idem pour le status stream si jamais un test le déclenche indirectement
    when(() => roomRepo.roomStatusStream(any()))
        .thenAnswer((_) => const Stream<RoomGameStatus>.empty());

    bloc = RoomBloc(roomRepository: roomRepo, userRepository: userRepo);
  });

  tearDown(() => bloc.close());

  blocTest<RoomBloc, RoomState>(
    'createRoom → [creatingRoom, roomCreated] + écoute joueurs',
    build: () {
      when(() => roomRepo.createRoom(any())).thenAnswer((_) async => room);
      when(() => userRepo.getCurrentUser()).thenAnswer((_) async => user);
      when(() => roomRepo.autoDeleteRoom(any())).thenAnswer((_) async {});
      return bloc;
    },
    act: (b) => b.add(CreateRoomEvent(roomEntity: room)),
    expect: () => [
      isA<RoomState>().having((s) => s.status, 'status', RoomStatus.creatingRoom),
      isA<RoomState>().having((s) => s.status, 'status', RoomStatus.roomCreated),
      // L’event ListenPlayersEvent est dispatché, puis forEach émettra soit rien (Stream.empty),
      // soit un playersUpdated si tu mocks un Stream avec des données.
    ],
    verify: (_) {
      verify(() => roomRepo.createRoom(any())).called(1);
      verify(() => userRepo.getCurrentUser()).called(1);
      verify(() => roomRepo.autoDeleteRoom(room.roomId)).called(1);
      verify(() => roomRepo.playersStream(room.roomId)).called(1);
    },
  );

  blocTest<RoomBloc, RoomState>(
    'createRoom → erreur → [creatingRoom, error]',
    build: () {
      when(() => roomRepo.createRoom(any())).thenThrow(Exception('create fail'));
      return bloc;
    },
    act: (b) => b.add(CreateRoomEvent(roomEntity: room)),
    expect: () => [
      isA<RoomState>().having((s) => s.status, 'status', RoomStatus.creatingRoom),
      isA<RoomState>().having((s) => s.status, 'status', RoomStatus.error),
    ],
  );

  blocTest<RoomBloc, RoomState>(
    'joinRoom → [joiningRoom, roomCreated] + écoute joueurs',
    build: () {
      when(() => roomRepo.joinRoom(any(), any())).thenAnswer((_) async {});
      when(() => roomRepo.getAvailableRooms()).thenAnswer((_) async => [room]);
      return bloc;
    },
    act: (b) => b.add(JoinRoomEvent(roomId: 'r1', userEntity: user)),
    expect: () => [
      isA<RoomState>().having((s) => s.status, 'status', RoomStatus.joiningRoom),
      isA<RoomState>().having((s) => s.status, 'status', RoomStatus.roomCreated),
    ],
    verify: (_) {
      verify(() => roomRepo.joinRoom('r1', user)).called(1);
      verify(() => roomRepo.getAvailableRooms()).called(1);
      verify(() => roomRepo.playersStream('r1')).called(1);
    },
  );

  blocTest<RoomBloc, RoomState>(
    'leaveRoom → [roomLeft]',
    build: () {
      when(() => roomRepo.leaveRoom(any(), any())).thenAnswer((_) async {});
      return bloc;
    },
    act: (b) => b.add(LeaveRoomEvent(roomId: 'r1', userEntity: user)),
    expect: () => [
      isA<RoomState>().having((s) => s.status, 'status', RoomStatus.initial),
    ],
    verify: (_) => verify(() => roomRepo.leaveRoom('r1', user)).called(1),
  );

  blocTest<RoomBloc, RoomState>(
    'deleteRoom → [roomDeleted]',
    build: () {
      when(() => roomRepo.deleteRoom(any())).thenAnswer((_) async {});
      return bloc;
    },
    act: (b) => b.add(DeleteRoomEvent(roomId: 'r1')),
    expect: () => [
      isA<RoomState>().having((s) => s.status, 'status', RoomStatus.roomDeleted),
    ],
    verify: (_) => verify(() => roomRepo.deleteRoom('r1')).called(1),
  );

  blocTest<RoomBloc, RoomState>(
    'fetchAvailableRooms → [loadingRooms, loaded]',
    build: () {
      when(() => roomRepo.getAvailableRooms()).thenAnswer((_) async => [room]);
      return bloc;
    },
    act: (b) => b.add(FetchAvailableRoomsEvent()),
    expect: () => [
      isA<RoomState>().having((s) => s.status, 'status', RoomStatus.loadingRooms),
      isA<RoomState>()
          .having((s) => s.status, 'status', RoomStatus.loaded)
          .having((s) => s.availableRooms.length, 'rooms len', 1),
    ],
    verify: (_) => verify(() => roomRepo.getAvailableRooms()).called(1),
  );

  blocTest<RoomBloc, RoomState>(
    'startGame → aucune émission (juste appel repo)',
    build: () {
      when(() => roomRepo.startGame(any())).thenAnswer((_) async {});
      return bloc;
    },
    act: (b) => b.add(StartGameEvent(roomId: 'r1')),
    expect: () => [],
    verify: (_) => verify(() => roomRepo.startGame('r1')).called(1),
  );

  blocTest<RoomBloc, RoomState>(
    'updateFinalScore → [updatingScore, scoreUpdated]',
    build: () {
      when(() => userRepo.updateScore(any(), any())).thenAnswer((_) async {});
      when(() => roomRepo.updateRoomScore(any(), any(), any())).thenAnswer((_) async {});
      when(() => roomRepo.getRoomById(any())).thenAnswer((_) async => room);
      return bloc;
    },
    act: (b) => b.add(UpdateFinalScoreEvent(roomId: 'r1', userId: 'u1', newScore: 80)),
    expect: () => [
      isA<RoomState>().having((s) => s.status, 'status', RoomStatus.updatingScore),
      isA<RoomState>()
          .having((s) => s.status, 'status', RoomStatus.scoreUpdated)
          .having((s) => s.currentRoom?.roomId, 'roomId', 'r1'),
    ],
    verify: (_) {
      verify(() => userRepo.updateScore('u1', 80)).called(1);
      verify(() => roomRepo.updateRoomScore('r1', 'u1', 80)).called(1);
      verify(() => roomRepo.getRoomById('r1')).called(1);
    },
  );

  blocTest<RoomBloc, RoomState>(
    'getRoomById → [fetchingRoomById]',
    build: () {
      when(() => roomRepo.getRoomById(any())).thenAnswer((_) async => room);
      return bloc;
    },
    act: (b) => b.add(GetRoomByIdEvent(roomId: 'r1')),
    expect: () => [
      isA<RoomState>()
          .having((s) => s.status, 'status', RoomStatus.fetchingRoomById)
          .having((s) => s.currentRoom?.roomId, 'roomId', 'r1'),
    ],
    verify: (_) => verify(() => roomRepo.getRoomById('r1')).called(1),
  );
}
