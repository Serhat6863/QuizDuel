import 'package:firebase_database/firebase_database.dart';
import 'package:quizduel/core/error/app_failure.dart';
import 'package:quizduel/core/utils/logger.dart';
import 'package:quizduel/features/auth/data/model/user_model.dart';
import 'package:quizduel/features/room/domain/enums/room_game_status.dart';
import '../model/room_model.dart';

class FirebaseRoomService {
  final DatabaseReference db = FirebaseDatabase.instance.ref();

  // 🔹 CREATE ROOM
  Future<RoomModel?> createRoom(RoomModel room) async {
    try {
      logger.i("🛠️ Creating a new room for ${room.hostId}...");

      final roomRef = db.child("rooms").push();
      final roomId = roomRef.key ?? "unknown";

      final Map<String, dynamic> userData = {
        for (var u in room.user)
          u.id: (u is UserModel
              ? u.toJson()
              : UserModel(
            id: u.id,
            email: u.email,
            username: u.username,
            isReady: u.isReady,
            score: u.score,
            isOnline: u.isOnline,
            deviceId: u.deviceId,
          ).toJson())
      };

      final roomData = {
        ...room.toJson(),
        "roomId": roomId,
        "user": userData,
        "status": "waiting",
        "createdAt": DateTime.now().toIso8601String(),
      };

      await roomRef.set(roomData);
      logger.i("✅ Room created successfully: $roomId");

      return RoomModel.fromJson(roomData);
    } catch (e, s) {
      logger.e("❌ Failed to create room: $e", error: e, stackTrace: s);
      throw AppFailure(
        message: "Failed to create room: ${e.toString()}",
        code: "create-room-failed",
      );
    }
  }

  // 🔹 AUTO DELETE ON DISCONNECT
  Future<void> setAutoDeleteOnDisconnect(String roomId) async {
    try {
      logger.i("⚙️ Setting up auto-delete for room $roomId...");
      final roomRef = db.child("rooms/$roomId");
      await roomRef.onDisconnect().remove();
      logger.i("🗑️ Auto-delete configured for room $roomId");
    } catch (e, s) {
      logger.e("❌ Failed to set auto-delete: $e", error: e, stackTrace: s);
      throw AppFailure(
        message: "Failed to set auto-delete: $e",
        code: "auto-delete-failed",
      );
    }
  }

  // 🔹 DELETE ROOM
  Future<void> deleteRoom(String roomId) async {
    try {
      logger.i("🗑️ Deleting room $roomId...");
      await db.child("rooms/$roomId").remove();
      logger.i("✅ Room $roomId deleted successfully");
    } catch (e, s) {
      logger.e("❌ Failed to delete room: $e", error: e, stackTrace: s);
      throw AppFailure(
        message: "Failed to delete room: ${e.toString()}",
        code: "delete-room-failed",
      );
    }
  }

  // 🔹 JOIN ROOM
  // 🔹 JOIN ROOM
  Future<void> joinRoom(String roomId, UserModel user) async {
    try {
      logger.i("👥 ${user.username} is trying to join room $roomId...");

      // 🧩 1. Vérifier si la room existe
      final roomSnapshot = await db.child("rooms/$roomId").get();
      if (!roomSnapshot.exists) {
        throw AppFailure(
          message: "Room $roomId does not exist.",
          code: "room-not-found",
        );
      }

      // 🧩 2. Récupérer les données de la room
      final roomData = Map<String, dynamic>.from(roomSnapshot.value as Map);

      // 🧩 3. Récupérer les utilisateurs actuels
      final currentUsers = roomData['user'] != null
          ? Map<String, dynamic>.from(roomData['user'])
          : <String, dynamic>{};

      // 🧩 4. Vérifier la capacité max
      final int maxPlayers = roomData['maxPlayers'] ?? 4;
      if (currentUsers.length >= maxPlayers) {
        throw AppFailure(
          message: "Room $roomId is already full.",
          code: "room-full",
        );
      }

      // 🧩 5. Vérifier le statut de la room
      final String status = roomData['status'] ?? 'waiting';
      final String roomName = roomData['roomName'] ?? roomId;
      if (status != 'waiting') {
        throw AppFailure(
          message:
          "Cannot join room $roomName as the game has already started.",
          code: "game-already-started",
        );
      }

      // 🧩 6. Ajouter l'utilisateur dans la room
      final userRef = db.child("rooms/$roomId/user/${user.id}");
      await userRef.set(user.toJson());

      logger.i("✅ ${user.username} joined room $roomId successfully.");
    } catch (e, s) {
      logger.e("❌ Error joining room: $e", error: e, stackTrace: s);
      throw AppFailure(
        message: "Error while joining room: ${_extractMessage(e)}",
        code: _extractCode(e),
      );
    }
  }


  // 🔹 LEAVE ROOM
  Future<void> leaveRoom(String roomId, UserModel user) async {
    try {
      logger.i("🚪 ${user.username} is leaving room $roomId...");
      final userRef = db.child("rooms/$roomId/user/${user.id}");
      await userRef.remove();
      logger.i("✅ ${user.username} left room $roomId.");
    } catch (e, s) {
      logger.e("❌ Failed to leave room: $e", error: e, stackTrace: s);
      throw AppFailure(
        message: "Error while leaving room: ${_extractMessage(e)}",
        code: _extractCode(e),
      );
    }
  }

  // 🔹 FETCH AVAILABLE ROOMS
  Future<List<RoomModel>> getAvailableRooms() async {
    try {
      logger.i("📡 Fetching available rooms...");
      final snapshot = await db.child("rooms").get();

      if (snapshot.exists && snapshot.value is Map) {
        final rawMap = snapshot.value as Map<Object?, Object?>;
        final rooms = rawMap.entries.map((entry) {
          final roomData = deepCast(entry.value as Map);
          return RoomModel.fromJson(roomData);
        }).toList();

        logger.i("✅ ${rooms.length} available rooms found.");
        return rooms;
      }

      logger.w("⚠️ No rooms found in the database.");
      return [];
    } catch (e, s) {
      logger.e("❌ Failed to fetch rooms: $e", error: e, stackTrace: s);
      throw AppFailure(
        message: "Failed to fetch rooms: ${_extractMessage(e)}",
        code: _extractCode(e),
      );
    }
  }

  // 🔹 DEEP CAST MAP
  Map<String, dynamic> deepCast(Map input) {
    return input.map((key, value) {
      if (value is Map) {
        return MapEntry(key.toString(), deepCast(value));
      } else if (value is List) {
        return MapEntry(
          key.toString(),
          value.map((e) => e is Map ? deepCast(e) : e).toList(),
        );
      } else {
        return MapEntry(key.toString(), value);
      }
    });
  }

  // 🔹 PLAYER LIST STREAM
  Stream<List<UserModel>> playerListStream(String roomId) {
    final usersRef = db.child("rooms/$roomId/user");
    logger.d("👂 Listening to player updates for room $roomId...");

    return usersRef.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) {
        logger.w("⚠️ No players detected in room $roomId.");
        return [];
      }

      final players = data.values.map((userData) {
        return UserModel.fromJson(Map<String, dynamic>.from(userData));
      }).toList();

      logger.t("👥 ${players.length} players currently in room $roomId.");
      return players;
    });
  }

  // 🔹 ROOM STATUS STREAM
  Stream<RoomGameStatus> roomStatusStream(String roomId) {
    try {
      final statusRef = db.child("rooms/$roomId/status");
      logger.d("👂 Listening to room status updates for $roomId...");
      return statusRef.onValue.map((event) {
        final rawStatus = event.snapshot.value?.toString() ?? 'waiting';
        logger.i("🎯 Room $roomId status updated → $rawStatus");
        return RoomGameStatusX.fromString(rawStatus);
      });
    } catch (e) {
      throw AppFailure(
        message: "Error while streaming room status: ${_extractMessage(e)}",
        code: _extractCode(e),
      );
    }
  }

  // 🔹 START GAME
  Future<void> startGame(String roomId) async {
    try {
      logger.i("▶️ Starting game in room $roomId...");
      final statusRef = db.child("rooms/$roomId/status");
      await statusRef.set(RoomGameStatus.playing.toShortString());
      logger.i("🔥 Room status updated → playing");
    } catch (e, s) {
      logger.e("❌ Failed to start game: $e", error: e, stackTrace: s);
      throw AppFailure(
        message: "Error while starting the game: ${_extractMessage(e)}",
        code: _extractCode(e),
      );
    }
  }

  // 🔹 UPDATE ROOM SCORE
  Future<void> updateRoomScore(String roomId, String userId, int newScore) async {
    try {
      logger.i("🔄 Updating score for user $userId in room $roomId → $newScore");
      final scoreRef = db.child("rooms/$roomId/user/$userId/score");
      await scoreRef.set(newScore);
      logger.i("✅ Score updated successfully for $userId in room $roomId");
    } catch (e, s) {
      logger.e("❌ Failed to update score: $e", error: e, stackTrace: s);
      throw AppFailure(
        message: "Error while updating score: ${_extractMessage(e)}",
        code: _extractCode(e),
      );
    }
  }

  // 🔹 GET ROOM BY ID
  Future<RoomModel> getRoomById(String roomId) async {
    try {
      logger.i("🔍 Fetching room by ID: $roomId");
      final roomRef = db.child("rooms/$roomId");
      final snapshot = await roomRef.get();

      if (snapshot.exists && snapshot.value is Map) {
        final roomData = deepCast(snapshot.value as Map);
        final room = RoomModel.fromJson(roomData);
        logger.i("✅ Room $roomId fetched successfully.");
        return room;
      } else {
        throw AppFailure(message: "Room not found with ID: $roomId", code: "room-not-found");
      }
    } catch (e) {
      throw AppFailure(
        message: "Error while fetching room by ID: ${_extractMessage(e)}",
        code: _extractCode(e),
      );
    }
  }

  // 🔧 Helpers
  String _extractMessage(Object e) => e is AppFailure ? e.message : e.toString();
  String _extractCode(Object e) => e is AppFailure ? e.code : 'unknown';
}
