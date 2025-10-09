import 'package:firebase_database/firebase_database.dart';
import 'package:quizduel/core/utils/logger.dart';
import 'package:quizduel/features/auth/data/model/user_model.dart';
import 'package:quizduel/features/room/domain/enums/room_game_status.dart';
import '../model/room_model.dart';

class FirebaseRoomService {
  final DatabaseReference db = FirebaseDatabase.instance.ref();

  // ✅ CREATE ROOM
  Future<RoomModel?> createRoom(RoomModel room) async {
    try {
      logger.i("🛠️ Tentative de création d'une room pour ${room.hostId}");

      final roomRef = db.child("rooms").push();
      final roomId = roomRef.key ?? "unknown";

      logger.d("🆔 Génération d’un nouvel ID de room: $roomId");

      // 🔄 Conversion des users
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
          ).toJson())
      };

      final roomData = {
        ...room.toJson(),
        "roomId": roomId,
        "user": userData,
        "status": "waiting", // ✅ status initial
        "createdAt": DateTime.now().toIso8601String(),
      };

      logger.d("📤 Envoi des données Firebase pour la room $roomId");
      await roomRef.set(roomData);
      logger.i("✅ Room créée avec succès: $roomId");

      return RoomModel.fromJson(roomData);
    } catch (e, s) {
      logger.e("❌ Erreur lors de la création de la room: $e", error: e, stackTrace: s);
      throw Exception("Erreur création room: $e");
    }
  }

  // ✅ AUTO DELETE ON DISCONNECT
  Future<void> setAutoDeleteOnDisconnect(String roomId) async {
    try {
      logger.i("⚙️ Configuration de la suppression auto pour $roomId");
      final roomRef = db.child("rooms/$roomId");
      await roomRef.onDisconnect().remove();
      logger.i("🗑️ Suppression automatique activée pour $roomId");
    } catch (e, s) {
      logger.e("❌ Erreur lors de l'activation de la suppression automatique: $e",
          error: e, stackTrace: s);
      throw Exception("Erreur suppression auto: $e");
    }
  }

  // ✅ DELETE ROOM
  Future<void> deleteRoom(String roomId) async {
    try {
      logger.i("🗑️ Suppression manuelle de la room $roomId");
      await db.child("rooms/$roomId").remove();
      logger.i("✅ Room $roomId supprimée avec succès");
    } catch (e, s) {
      logger.e("❌ Erreur lors de la suppression de la room $roomId: $e", error: e, stackTrace: s);
      throw Exception("Erreur suppression room: $e");
    }
  }

  // ✅ JOIN ROOM
  Future<void> joinRoom(String roomId, UserModel user) async {
    try {
      logger.i("👥 ${user.username} tente de rejoindre la room $roomId");
      final userRef = db.child("rooms/$roomId/user/${user.id}");
      await userRef.set(user.toJson());
      logger.i("✅ ${user.username} a rejoint la room $roomId");
    } catch (e, s) {
      logger.e("❌ Erreur lors de la jointure de la room $roomId: $e", error: e, stackTrace: s);
      throw Exception("Erreur join room: $e");
    }
  }

  // ✅ LEAVE ROOM
  Future<void> leaveRoom(String roomId, UserModel user) async {
    try {
      logger.i("🚪 ${user.username} quitte la room $roomId");
      final userRef = db.child("rooms/$roomId/user/${user.id}");
      await userRef.remove();
      logger.i("✅ ${user.username} a quitté la room $roomId");
    } catch (e, s) {
      logger.e("❌ Erreur lors du départ de la room $roomId: $e", error: e, stackTrace: s);
      throw Exception("Erreur leave room: $e");
    }
  }

  // ✅ FETCH ROOMS
  Future<List<RoomModel>> getAvailableRooms() async {
    try {
      logger.i("📡 Récupération des rooms disponibles...");
      final snapshot = await db.child("rooms").get();

      if (snapshot.exists && snapshot.value is Map) {
        final rawMap = snapshot.value as Map<Object?, Object?>;

        final rooms = rawMap.entries.map((entry) {
          final roomData = deepCast(entry.value as Map);
          return RoomModel.fromJson(roomData);
        }).toList();

        logger.i("✅ ${rooms.length} rooms trouvées");
        return rooms;
      }

      logger.w("⚠️ Aucune room trouvée dans Firebase");
      return [];
    } catch (e, s) {
      logger.e("❌ Erreur lors de la récupération des rooms: $e", error: e, stackTrace: s);
      throw Exception("Erreur fetch rooms: $e");
    }
  }

  // ✅ DEEP CAST MAP
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

  // ✅ PLAYER LIST STREAM
  Stream<List<UserModel>> playerListStream(String roomId) {
    final usersRef = db.child("rooms/$roomId/user");
    logger.d("👂 Stream des joueurs actif pour la room $roomId");

    return usersRef.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) {
        logger.w("⚠️ Aucun joueur détecté dans la room $roomId");
        return [];
      }

      final players = data.values.map((userData) {
        return UserModel.fromJson(Map<String, dynamic>.from(userData));
      }).toList();

      logger.t("👥 ${players.length} joueurs détectés dans $roomId");
      return players;
    });
  }


  // ✅ STATUS STREAM (corrigé)
  Stream<RoomGameStatus> roomStatusStream(String roomId) {
    try {
      final statusRef = db.child("rooms/$roomId/status"); // ✅ corrigé ici
      logger.d("👂 Stream du status actif pour la room $roomId");

      return statusRef.onValue.map((event) {
        final rawStatus = event.snapshot.value?.toString() ?? 'waiting';
        logger.i("🎯 Status mis à jour pour $roomId → $rawStatus");
        return RoomGameStatusX.fromString(rawStatus);
      });
    } catch (e, s) {
      logger.e("❌ Erreur lors du stream du status de la room $roomId: $e",
          error: e, stackTrace: s);
      throw Exception("Erreur room status stream: $e");
    }
  }

  // ✅ START GAME
  Future<void> startGame(String roomId) async {
    try {
      logger.i("▶️ Démarrage du jeu dans la room $roomId");
      final statusRef = db.child("rooms/$roomId/status");
      await statusRef.set(RoomGameStatus.playing.toShortString());
      logger.i("🔥 Status mis à jour dans Firebase → ${RoomGameStatus.playing.toShortString()}");
    } catch (e, s) {
      logger.e("❌ Erreur lors du démarrage du jeu dans la room $roomId: $e",
          error: e, stackTrace: s);
      throw Exception("Erreur start game: $e");
    }
  }

  //update room score
  Future<void> updateRoomScore(String roomId, String userId, int newScore) async {
    try{
      logger.i("🔄 Mise à jour du score pour l'utilisateur $userId dans la room $roomId à $newScore");
      final scoreRef = db.child("rooms/$roomId/user/$userId/score");
      await scoreRef.set(newScore);
      logger.i("✅ Score mis à jour pour l'utilisateur $userId dans la room $roomId à $newScore");
    }catch(e){
      logger.e("❌ Erreur lors de la mise à jour du score pour l'utilisateur $userId dans la room $roomId: $e", error: e);
      throw Exception("Something went wrong while updating the score: $e");
    }
  }


  //get room by id
  Future<RoomModel> getRoomById(String roomId) async {
    try{
      logger.i("🔍 Récupération de la room par ID: $roomId");
      final roomRef = db.child("rooms/$roomId");
      final snapshot = await roomRef.get();

      if (snapshot.exists && snapshot.value is Map) {
        final roomData = deepCast(snapshot.value as Map);
        final room = RoomModel.fromJson(roomData);
        logger.i("✅ Room récupérée avec succès: $roomId");
        return room;
      } else {
        logger.w("⚠️ Aucune room trouvée avec l'ID: $roomId");
        throw Exception("Room not found with ID: $roomId");
      }

    }catch(e){
      throw Exception("Something went wrong while getting the room by id: $e");
    }
  }

}
