import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizduel/core/error/app_failure.dart';
import 'package:quizduel/core/utils/logger.dart';
import 'package:quizduel/features/auth/domain/entity/user_entity.dart';
import 'package:quizduel/features/room/domain/enums/room_game_status.dart';
import 'package:quizduel/features/room/domain/repository/room_repository.dart';
import 'package:quizduel/features/auth/domain/repository/user_repository.dart';
import 'room_event.dart';
import 'room_state.dart';

class RoomBloc extends Bloc<RoomEvent, RoomState> {
  final RoomRepository roomRepository;
  final UserRepository userRepository;

  RoomBloc({
    required this.roomRepository,
    required this.userRepository,
  }) : super(RoomState.initial()) {
    on<CreateRoomEvent>(_onCreateRoom);
    on<JoinRoomEvent>(_onJoinRoom);
    on<LeaveRoomEvent>(_onLeaveRoom);
    on<DeleteRoomEvent>(_onDeleteRoom);
    on<FetchAvailableRoomsEvent>(_onFetchAvailableRooms);
    on<ListenPlayersEvent>(_onListenPlayers);
    on<ListenStatusEvent>(_onListenStatus);
    on<StartGameEvent>(_onStartGame);
    on<UpdateFinalScoreEvent>(_onUpdateFinalScore);
    on<GetRoomByIdEvent>(_onGetRoomById);
  }

  // 🔹 CREATE ROOM
  Future<void> _onCreateRoom(
      CreateRoomEvent event,
      Emitter<RoomState> emit,
      ) async {
    logger.i("🛠️ Creating room: ${event.roomEntity.roomName}");
    emit(RoomState.creatingRoom());

    try {
      final room = await roomRepository.createRoom(event.roomEntity);

      if (room == null) {
        logger.w("⚠️ Room creation failed — returned null");
        emit(RoomState.error("Failed to create room."));
        return;
      }

      final currentUser = await userRepository.getCurrentUser();
      if (currentUser != null && room.hostId == currentUser.id) {
        await roomRepository.autoDeleteRoom(room.roomId);
        logger.d("🧹 Auto-delete enabled for room ${room.roomId}");
      }

      logger.i("✅ Room '${room.roomName}' successfully created (${room.roomId})");
      emit(RoomState.roomCreated(room));

      add(ListenPlayersEvent(roomId: room.roomId));
    } catch (e, s) {
      logger.e("❌ Error while creating room", error: e, stackTrace: s);
      emit(RoomState.error(_extractMessage(e)));
    }
  }

  // 🔹 JOIN ROOM
  Future<void> _onJoinRoom(
      JoinRoomEvent event,
      Emitter<RoomState> emit,
      ) async {
    logger.i("👥 Attempting to join room ${event.roomId}");
    emit(RoomState.joiningRoom());

    try {
      await roomRepository.joinRoom(event.roomId, event.userEntity);

      final rooms = await roomRepository.getAvailableRooms();
      final joinedRoom = rooms.firstWhere(
            (r) => r.roomId == event.roomId,
        orElse: () {
          logger.w("⚠️ Room ${event.roomId} not found after join attempt");
          throw AppFailure(message: "Room not found", code: "room-not-found");
        },
      );

      logger.i("✅ ${event.userEntity.username} joined room ${event.roomId}");
      emit(RoomState.roomCreated(joinedRoom));

      add(ListenPlayersEvent(roomId: event.roomId));
    } catch (e, s) {
      logger.e("❌ Error joining room ${event.roomId}", error: e, stackTrace: s);
      emit(RoomState.error(_extractMessage(e)));
    }
  }

  // 🔹 LEAVE ROOM
  Future<void> _onLeaveRoom(
      LeaveRoomEvent event,
      Emitter<RoomState> emit,
      ) async {
    logger.i("🚪 ${event.userEntity.username} leaving room ${event.roomId}");
    try {
      await roomRepository.leaveRoom(event.roomId, event.userEntity);
      logger.i("✅ ${event.userEntity.username} left room ${event.roomId}");
      emit(RoomState.roomLeft());
    } catch (e, s) {
      logger.e("❌ Error leaving room ${event.roomId}", error: e, stackTrace: s);
      emit(RoomState.error(_extractMessage(e)));
    }
  }

  // 🔹 DELETE ROOM
  Future<void> _onDeleteRoom(
      DeleteRoomEvent event,
      Emitter<RoomState> emit,
      ) async {
    logger.w("🗑️ Deleting room ${event.roomId}");
    try {
      await roomRepository.deleteRoom(event.roomId);
      logger.i("✅ Room ${event.roomId} deleted successfully");
      emit(RoomState.roomDeleted());
    } catch (e, s) {
      logger.e("❌ Error deleting room ${event.roomId}", error: e, stackTrace: s);
      emit(RoomState.error(_extractMessage(e)));
    }
  }

  // 🔹 FETCH ROOMS
  Future<void> _onFetchAvailableRooms(
      FetchAvailableRoomsEvent event,
      Emitter<RoomState> emit,
      ) async {
    logger.d("📡 Fetching available rooms...");
    emit(RoomState.loadingRooms());

    try {
      final rooms = await roomRepository.getAvailableRooms();
      logger.i("✅ ${rooms.length} rooms fetched from Firebase");
      emit(RoomState.roomLoaded(rooms));
    } catch (e, s) {
      logger.e("❌ Error fetching rooms", error: e, stackTrace: s);
      emit(RoomState.error(_extractMessage(e)));
    }
  }

  // 🔹 LISTEN PLAYERS STREAM
  Future<void> _onListenPlayers(
      ListenPlayersEvent event,
      Emitter<RoomState> emit,
      ) async {
    logger.d("👂 Listening to players in room ${event.roomId}");
    await emit.forEach<List<UserEntity>>(
      roomRepository.playersStream(event.roomId),
      onData: (players) {
        logger.d("📢 ${players.length} players detected in ${event.roomId}");
        return state.copyWith(
          status: RoomStatus.playersUpdated,
          players: players,
        );
      },
      onError: (error, _) {
        logger.e("❌ Player stream error for ${event.roomId}", error: error);
        return RoomState.error(_extractMessage(error));
      },
    );
  }

  // 🔹 LISTEN STATUS STREAM
  Future<void> _onListenStatus(
      ListenStatusEvent event,
      Emitter<RoomState> emit,
      ) async {
    try {
      logger.d("👂 Listening to room status for ${event.roomId}");
      await emit.forEach<RoomGameStatus>(
        roomRepository.roomStatusStream(event.roomId),
        onData: (status) {
          logger.d("📢 Room ${event.roomId} status updated → $status");

          if (status.isPlaying) {
            return RoomState.gameStarted(state.currentRoom!);
          } else {
            return state;
          }
        },
        onError: (error, _) {
          logger.e("❌ Status stream error for ${event.roomId}", error: error);
          return RoomState.error(_extractMessage(error));
        },
      );
    } catch (e) {
      logger.e("❌ Error listening to room status ${event.roomId}", error: e);
      emit(RoomState.error(_extractMessage(e)));
    }
  }

  // 🔹 START GAME
  Future<void> _onStartGame(StartGameEvent event, Emitter<RoomState> emit) async {
    try {
      logger.i("▶️ Starting game in room ${event.roomId}");
      await roomRepository.startGame(event.roomId);
      logger.i("✅ Game started successfully in ${event.roomId}");
    } catch (e) {
      logger.e("❌ Error starting game in ${event.roomId}", error: e);
      emit(RoomState.error(_extractMessage(e)));
    }
  }

  // 🔹 UPDATE FINAL SCORE
  Future<void> _onUpdateFinalScore(UpdateFinalScoreEvent event, Emitter<RoomState> emit) async {
    emit(state.copyWith(status: RoomStatus.updatingScore));

    try {
      logger.i("🔄 Updating final score for ${event.userId} → ${event.newScore} (room ${event.roomId})");

      await userRepository.updateScore(event.userId, event.newScore);
      await roomRepository.updateRoomScore(event.roomId, event.userId, event.newScore);

      final updatedRoom = await roomRepository.getRoomById(event.roomId);
      logger.i("✅ Scores updated successfully in room ${event.roomId}");

      emit(RoomState.scoreUpdated(updatedRoom));
    } catch (e, s) {
      logger.e("❌ Error updating final score for ${event.userId}", error: e, stackTrace: s);
      emit(RoomState.error(_extractMessage(e)));
    }
  }

  // 🔹 GET ROOM BY ID
  Future<void> _onGetRoomById(GetRoomByIdEvent event, Emitter<RoomState> emit) async {
    try {
      logger.d("🔍 Fetching room by ID: ${event.roomId}");
      final room = await roomRepository.getRoomById(event.roomId);
      emit(RoomState.fetchingRoomById(room));
    } catch (e) {
      logger.e("❌ Error fetching room ${event.roomId}", error: e);
      emit(RoomState.error(_extractMessage(e)));
    }
  }

  // 🔧 Helpers for AppFailure extraction
  String _extractMessage(Object e) =>
      e is AppFailure ? e.message : "An unexpected error occurred.";
}
