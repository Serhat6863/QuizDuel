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

  // ✅ CREATE ROOM
  @override
  Future<RoomEntity?> createRoom(RoomEntity room) async {
    try {
      logger.i("🛠️ Création d'une nouvelle room '${room.roomName}' par host ${room.hostId}");

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
          logger.w("⚠️ Délai dépassé pour la création de la room '${room.roomName}'");
          throw Exception("Room creation timed out");
        },
      );

      if (createdRoom != null) {
        logger.i("✅ Room '${createdRoom.roomName}' créée avec succès (id: ${createdRoom.roomId})");
        return createdRoom.toEntity();
      } else {
        logger.w("⚠️ Firebase a renvoyé null lors de la création de la room '${room.roomName}'");
        return null;
      }
    } catch (e, s) {
      logger.e("❌ Erreur lors de la création de la room '${room.roomName}': $e", error: e, stackTrace: s);
      throw Exception("Something went wrong while creating room: $e");
    }
  }

  // ✅ DELETE ROOM
  @override
  Future<void> deleteRoom(String roomId) async {
    try {
      logger.i("🗑️ Suppression de la room $roomId");
      await firebaseRoomService.deleteRoom(roomId);
      logger.i("✅ Room $roomId supprimée avec succès");
    } catch (e, s) {
      logger.e("❌ Erreur lors de la suppression de la room $roomId: $e", error: e, stackTrace: s);
      throw Exception("Something went wrong while deleting room: $e");
    }
  }

  // ✅ FETCH ROOMS
  @override
  Future<List<RoomEntity>> getAvailableRooms() async {
    try {
      logger.i("📡 Récupération des rooms disponibles depuis Firebase...");
      final rooms = await firebaseRoomService.getAvailableRooms();
      logger.i("✅ ${rooms.length} rooms récupérées depuis Firebase");
      return rooms.map((room) => room.toEntity()).toList();
    } catch (e, s) {
      logger.e("❌ Erreur lors de la récupération des rooms: $e", error: e, stackTrace: s);
      throw Exception("Something went wrong while fetching available rooms: $e");
    }
  }

  // ✅ JOIN ROOM
  @override
  Future<void> joinRoom(String roomId, UserEntity user) async {
    try {
      final userModel = UserModel(
        id: user.id,
        email: user.email,
        username: user.username,
        isReady: user.isReady,
        score: user.score,
      );

      logger.i("👥 ${user.username} rejoint la room $roomId");
      await firebaseRoomService.joinRoom(roomId, userModel);
      logger.i("✅ ${user.username} a rejoint la room $roomId");
    } catch (e, s) {
      logger.e("❌ Erreur lors de la jointure de la room $roomId: $e", error: e, stackTrace: s);
      throw Exception("Something went wrong while joining room: $e");
    }
  }

  // ✅ LEAVE ROOM
  @override
  Future<void> leaveRoom(String roomId, UserEntity user) async {
    try {
      final userModel = UserModel(
        id: user.id,
        email: user.email,
        username: user.username,
        isReady: user.isReady,
        score: user.score,
      );

      logger.i("🚪 ${user.username} quitte la room $roomId");
      await firebaseRoomService.leaveRoom(roomId, userModel);
      logger.i("✅ ${user.username} a quitté la room $roomId");
    } catch (e, s) {
      logger.e("❌ Erreur lors du départ de la room $roomId: $e", error: e, stackTrace: s);
      throw Exception("Something went wrong while leaving room: $e");
    }
  }


  // ✅ AUTO DELETE
  @override
  Future<void> autoDeleteRoom(String roomId) async {
    try {
      logger.d("⚙️ Configuration de la suppression automatique pour $roomId");
      await firebaseRoomService.setAutoDeleteOnDisconnect(roomId);
      logger.i("✅ Suppression automatique configurée pour $roomId");
    } catch (e, s) {
      logger.e("❌ Erreur suppression auto de la room $roomId: $e", error: e, stackTrace: s);
      throw Exception("Something went wrong while setting up auto delete for room: $e");
    }
  }

  // ✅ PLAYERS STREAM
  @override
  Stream<List<UserEntity>> playersStream(String roomId) {
    try {
      logger.d("👂 Stream des joueurs actif pour la room $roomId");
      return firebaseRoomService.playerListStream(roomId).map(
            (userModels) => userModels.map((u) => u.toEntity()).toList(),
      );
    } catch (e, s) {
      logger.e("❌ Erreur lors du stream des joueurs pour la room $roomId: $e", error: e, stackTrace: s);
      throw Exception("Something went wrong while streaming players: $e");
    }
  }

  @override
  Stream<RoomGameStatus> roomStatusStream(String roomId) {
    try{
      logger.d("👂 Stream du status de la room $roomId");
      return firebaseRoomService.roomStatusStream(roomId).map(
            (status) => status,
      );
    } catch (e, s) {
      logger.e("❌ Erreur lors du stream du status pour la room $roomId: $e", error: e, stackTrace: s);
      throw Exception("Something went wrong while streaming room status: $e");
    }
  }

  @override
  Future<void> startGame(String roomId) async {
    try{
      logger.i("▶️ Démarrage du jeu pour la room $roomId");
      await firebaseRoomService.startGame(roomId);
      logger.i("✅ Jeu démarré pour la room $roomId");
    }catch(e){
      logger.e("❌ Erreur lors du démarrage du jeu pour la room $roomId: $e", error: e);
      throw Exception("Something went wrong while starting the game: $e");
    }
  }

  @override
  Future<void> updateRoomScore(String roomId, String userId, int newScore) async{
    try{
      logger.i("🔄 Mise à jour du score pour l'utilisateur $userId dans la room $roomId à $newScore");
      await firebaseRoomService.updateRoomScore(roomId, userId, newScore);
      logger.i("✅ Score mis à jour pour l'utilisateur $userId dans la room $roomId à $newScore");
    }catch(e){
      logger.e("❌ Erreur lors de la mise à jour du score pour l'utilisateur $userId dans la room $roomId: $e", error: e);
      throw Exception("Something went wrong while updating the score: $e");
    }
  }

  @override
  Future<RoomEntity> getRoomById(String roomId) async {
    try{
      final roomModel = await firebaseRoomService.getRoomById(roomId);
      if(roomModel == null){
        logger.w("⚠️ Aucune room trouvée avec l'ID $roomId");
        throw Exception("No room found with id: $roomId");
      }

      logger.i("✅ Room récupérée avec succès: $roomId");
      return roomModel.toEntity();
    }catch(e){
      logger.e("❌ Erreur lors de la récupération de la room $roomId: $e", error: e);
      throw Exception("Something went wrong while getting the room by id: $e");
    }
  }

}
