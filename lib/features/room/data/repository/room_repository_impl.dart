import 'package:quizduel/core/error/app_failure.dart';
import 'package:quizduel/core/utils/logger.dart';
import 'package:quizduel/features/auth/data/model/user_model.dart';
import 'package:quizduel/features/auth/domain/entity/user_entity.dart';
import 'package:quizduel/features/room/data/model/room_model.dart';
import 'package:quizduel/features/room/data/service/firebase_room_service.dart';
import 'package:quizduel/features/room/domain/entitiy/room_entity.dart';
import 'package:quizduel/features/room/domain/enums/room_game_status.dart';
import 'package:quizduel/features/room/domain/repository/room_repository.dart';

class RoomRepositoryImpl implements RoomRepository {
  final FirebaseRoomService firebaseRoomService;

  RoomRepositoryImpl({required this.firebaseRoomService});

  // 🔹 CREATE ROOM
  @override
  Future<RoomEntity?> createRoom(RoomEntity room) async {
    try {
      logger.i("🛠️ Creating a new room '${room.roomName}' by host ${room.hostId}");

      final roomModel = RoomModel(
        roomId: room.roomId,
        roomName: room.roomName,
        hostId: room.hostId,
        user: room.user,
        status: room.status,
        joinCode: room.joinCode,
        createdAt: room.createdAt,
        maxPlayers: room.maxPlayers,
        quiz: room.quiz,
      );

      final createdRoom = await firebaseRoomService.createRoom(roomModel).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          logger.w("⚠️ Room creation timed out for '${room.roomName}'");
          throw AppFailure(
            message: "Room creation timed out.",
            code: "timeout",
          );
        },
      );

      if (createdRoom != null) {
        logger.i("✅ Room '${createdRoom.roomName}' successfully created (id: ${createdRoom.roomId})");
        return createdRoom.toEntity();
      } else {
        throw AppFailure(
          message: "Firebase returned null while creating room '${room.roomName}'.",
          code: "null-room",
        );
      }
    } catch (e, s) {
      logger.e("❌ Error while creating room '${room.roomName}': $e", error: e, stackTrace: s);
      throw AppFailure(
        message: "Error while creating room: ${_extractMessage(e)}",
        code: _extractCode(e),
      );
    }
  }

  // 🔹 DELETE ROOM
  @override
  Future<void> deleteRoom(String roomId) async {
    try {
      logger.i("🗑️ Deleting room $roomId");
      await firebaseRoomService.deleteRoom(roomId);
      logger.i("✅ Room $roomId deleted successfully");
    } catch (e, s) {
      logger.e("❌ Error deleting room $roomId: $e", error: e, stackTrace: s);
      throw AppFailure(
        message: "Error while deleting room: ${_extractMessage(e)}",
        code: _extractCode(e),
      );
    }
  }

  // 🔹 FETCH ROOMS
  @override
  Future<List<RoomEntity>> getAvailableRooms() async {
    try {
      logger.i("📡 Fetching available rooms from Firebase...");
      final rooms = await firebaseRoomService.getAvailableRooms();
      logger.i("✅ ${rooms.length} rooms fetched from Firebase");
      return rooms.map((room) => room.toEntity()).toList();
    } catch (e, s) {
      logger.e("❌ Error fetching rooms: $e", error: e, stackTrace: s);
      throw AppFailure(
        message: "Error while fetching available rooms: ${_extractMessage(e)}",
        code: _extractCode(e),
      );
    }
  }

  // 🔹 JOIN ROOM
  @override
  Future<void> joinRoom(String roomId, UserEntity user) async {
    try {
      final userModel = UserModel(
        id: user.id,
        email: user.email,
        username: user.username,
        isReady: user.isReady,
        score: user.score,
        isOnline: user.isOnline,
        deviceId: user.deviceId,
      );

      logger.i("👥 ${user.username} joining room $roomId...");
      await firebaseRoomService.joinRoom(roomId, userModel);
      logger.i("✅ ${user.username} joined room $roomId");
    } catch (e, s) {
      logger.e("❌ Error joining room $roomId: $e", error: e, stackTrace: s);
      throw AppFailure(
        message: "Error while joining room: ${_extractMessage(e)}",
        code: _extractCode(e),
      );
    }
  }

  // 🔹 LEAVE ROOM
  @override
  Future<void> leaveRoom(String roomId, UserEntity user) async {
    try {
      final userModel = UserModel(
        id: user.id,
        email: user.email,
        username: user.username,
        isReady: user.isReady,
        score: user.score,
        isOnline: user.isOnline,
        deviceId: user.deviceId,
      );

      logger.i("🚪 ${user.username} leaving room $roomId...");
      await firebaseRoomService.leaveRoom(roomId, userModel);
      logger.i("✅ ${user.username} left room $roomId");
    } catch (e, s) {
      logger.e("❌ Error leaving room $roomId: $e", error: e, stackTrace: s);
      throw AppFailure(
        message: "Error while leaving room: ${_extractMessage(e)}",
        code: _extractCode(e),
      );
    }
  }

  // 🔹 AUTO DELETE ROOM
  @override
  Future<void> autoDeleteRoom(String roomId) async {
    try {
      logger.d("⚙️ Setting up auto-delete for $roomId");
      await firebaseRoomService.setAutoDeleteOnDisconnect(roomId);
      logger.i("✅ Auto-delete configured for $roomId");
    } catch (e, s) {
      logger.e("❌ Error setting auto-delete for $roomId: $e", error: e, stackTrace: s);
      throw AppFailure(
        message: "Error while setting up auto-delete: ${_extractMessage(e)}",
        code: _extractCode(e),
      );
    }
  }

  // 🔹 PLAYER STREAM
  @override
  Stream<List<UserEntity>> playersStream(String roomId) {
    try {
      logger.d("👂 Listening to players in room $roomId...");
      return firebaseRoomService.playerListStream(roomId).map(
            (userModels) => userModels.map((u) => u.toEntity()).toList(),
      );
    } catch (e, s) {
      logger.e("❌ Error streaming players for $roomId: $e", error: e, stackTrace: s);
      throw AppFailure(
        message: "Error while streaming players: ${_extractMessage(e)}",
        code: _extractCode(e),
      );
    }
  }

  // 🔹 ROOM STATUS STREAM
  @override
  Stream<RoomGameStatus> roomStatusStream(String roomId) {
    try {
      logger.d("👂 Listening to room status for $roomId...");
      return firebaseRoomService.roomStatusStream(roomId);
    } catch (e, s) {
      logger.e("❌ Error streaming room status for $roomId: $e", error: e, stackTrace: s);
      throw AppFailure(
        message: "Error while streaming room status: ${_extractMessage(e)}",
        code: _extractCode(e),
      );
    }
  }

  // 🔹 START GAME
  @override
  Future<void> startGame(String roomId) async {
    try {
      logger.i("▶️ Starting game for room $roomId...");
      await firebaseRoomService.startGame(roomId);
      logger.i("✅ Game started for room $roomId");
    } catch (e, s) {
      logger.e("❌ Error starting game for $roomId: $e", error: e, stackTrace: s);
      throw AppFailure(
        message: "Error while starting the game: ${_extractMessage(e)}",
        code: _extractCode(e),
      );
    }
  }

  // 🔹 UPDATE SCORE
  @override
  Future<void> updateRoomScore(String roomId, String userId, int newScore) async {
    try {
      logger.i("🔄 Updating score for user $userId in room $roomId → $newScore");
      await firebaseRoomService.updateRoomScore(roomId, userId, newScore);
      logger.i("✅ Score updated successfully for $userId in room $roomId");
    } catch (e, s) {
      logger.e("❌ Error updating score for $userId in $roomId: $e", error: e, stackTrace: s);
      throw AppFailure(
        message: "Error while updating score: ${_extractMessage(e)}",
        code: _extractCode(e),
      );
    }
  }

  // 🔹 GET ROOM BY ID
  @override
  Future<RoomEntity> getRoomById(String roomId) async {
    try {
      final roomModel = await firebaseRoomService.getRoomById(roomId);
      logger.i("✅ Room $roomId fetched successfully");
      return roomModel.toEntity();
    } catch (e, s) {
      logger.e("❌ Error fetching room $roomId: $e", error: e, stackTrace: s);
      throw AppFailure(
        message: "Error while fetching room by ID: ${_extractMessage(e)}",
        code: _extractCode(e),
      );
    }
  }

  // 🔧 Helpers to extract info from exceptions
  String _extractMessage(Object e) => e is AppFailure ? e.message : e.toString();
  String _extractCode(Object e) => e is AppFailure ? e.code : 'unknown';
}
