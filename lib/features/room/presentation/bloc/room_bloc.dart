import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizduel/core/utils/logger.dart';
import 'package:quizduel/features/auth/domain/entity/user_entity.dart';
import 'package:quizduel/features/room/domain/enums/room_game_status.dart';
import 'package:quizduel/features/room/domain/repository/room_repository.dart';
import 'package:quizduel/features/auth/domain/repository/user_repository.dart';
import '../../domain/entitiy/room_entity.dart';
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
  }

  /// ✅ Créer une room
  Future<void> _onCreateRoom(
      CreateRoomEvent event,
      Emitter<RoomState> emit,
      ) async {
    logger.i("🛠️ Création de la room: ${event.roomEntity.roomName}");
    emit(RoomState.creatingRoom());

    try {
      final room = await roomRepository.createRoom(event.roomEntity);

      if (room == null) {
        logger.w("⚠️ La création de la room a échoué, résultat null");
        emit(RoomState.error("Échec de la création de la room"));
        return;
      }

      final currentUser = await userRepository.getCurrentUser();
      if (currentUser != null && room.hostId == currentUser.id) {
        await roomRepository.autoDeleteRoom(room.roomId);
        logger.d("🧹 Auto-delete activé pour la room ${room.roomId}");
      }

      logger.i("✅ Room '${room.roomName}' créée avec succès (${room.roomId})");
      emit(RoomState.roomCreated(room));

      // Écoute des joueurs en live
      add(ListenPlayersEvent(roomId: room.roomId));
    } catch (e, s) {
      logger.e("❌ Erreur lors de la création de la room", error: e, stackTrace: s);
      emit(RoomState.error("Erreur création room: ${e.toString()}"));
    }
  }

  /// ✅ Rejoindre une room
  Future<void> _onJoinRoom(
      JoinRoomEvent event,
      Emitter<RoomState> emit,
      ) async {
    logger.i("👥 Tentative de rejoindre la room ${event.roomId}");
    emit(RoomState.joiningRoom());

    try {
      await roomRepository.joinRoom(event.roomId, event.userEntity);

      final rooms = await roomRepository.getAvailableRooms();
      final joinedRoom = rooms.firstWhere(
            (r) => r.roomId == event.roomId,
        orElse: () {
          logger.w("⚠️ Room ${event.roomId} introuvable après tentative de join");
          throw Exception("Room not found");
        },
      );

      logger.i("✅ ${event.userEntity.username} a rejoint la room ${event.roomId}");
      emit(RoomState.roomCreated(joinedRoom));

      add(ListenPlayersEvent(roomId: event.roomId));
    } catch (e, s) {
      logger.e("❌ Erreur lors de la jointure de la room ${event.roomId}", error: e, stackTrace: s);
      emit(RoomState.error("Erreur join room: ${e.toString()}"));
    }
  }

  /// ✅ Quitter une room
  Future<void> _onLeaveRoom(
      LeaveRoomEvent event,
      Emitter<RoomState> emit,
      ) async {
    logger.i("🚪 Tentative de quitter la room ${event.roomId}");
    try {
      await roomRepository.leaveRoom(event.roomId, event.userEntity);
      logger.i("✅ ${event.userEntity.username} a quitté la room ${event.roomId}");
      emit(RoomState.roomLeft());
    } catch (e, s) {
      logger.e("❌ Erreur lors du leave de la room ${event.roomId}", error: e, stackTrace: s);
      emit(RoomState.error("Erreur leave room: ${e.toString()}"));
    }
  }

  /// ✅ Supprimer une room
  Future<void> _onDeleteRoom(
      DeleteRoomEvent event,
      Emitter<RoomState> emit,
      ) async {
    logger.w("🗑️ Suppression manuelle de la room ${event.roomId}");
    try {
      await roomRepository.deleteRoom(event.roomId);
      logger.i("✅ Room ${event.roomId} supprimée avec succès");
      emit(RoomState.roomDeleted());
    } catch (e, s) {
      logger.e("❌ Erreur suppression room ${event.roomId}", error: e, stackTrace: s);
      emit(RoomState.error("Erreur suppression room: ${e.toString()}"));
    }
  }

  /// ✅ Récupérer les rooms disponibles
  Future<void> _onFetchAvailableRooms(
      FetchAvailableRoomsEvent event,
      Emitter<RoomState> emit,
      ) async {
    logger.d("📡 Récupération des rooms disponibles...");
    emit(RoomState.loadingRooms());

    try {
      final rooms = await roomRepository.getAvailableRooms();
      logger.i("✅ ${rooms.length} rooms récupérées depuis Firebase");
      emit(RoomState.roomLoaded(rooms));
    } catch (e, s) {
      logger.e("❌ Erreur lors du fetch des rooms", error: e, stackTrace: s);
      emit(RoomState.error("Erreur récupération rooms: ${e.toString()}"));
    }
  }

  /// ✅ Écouter les joueurs d’une room
  Future<void> _onListenPlayers(
      ListenPlayersEvent event,
      Emitter<RoomState> emit,
      ) async {
    logger.d("👂 Écoute en temps réel des joueurs de la room ${event.roomId}");
    await emit.forEach<List<UserEntity>>(
      roomRepository.playersStream(event.roomId),
      onData: (players) {
        logger.d("📢 ${players.length} joueurs dans la room ${event.roomId}");
        return state.copyWith(
          status: RoomStatus.playersUpdated,
          players: players,
        );
      },
      onError: (error, _) {
        logger.e("❌ Erreur dans le stream des joueurs de ${event.roomId}", error: error);
        return RoomState.error("Erreur stream players: ${error.toString()}");
      },
    );
  }


  Future<void> _onListenStatus(ListenStatusEvent event, Emitter<RoomState> emit) async {
    try {
      logger.d("👂 Écoute en temps réel du status de la room ${event.roomId}");
      await emit.forEach<RoomGameStatus>(
        roomRepository.roomStatusStream(event.roomId),
        onData: (status) {
          logger.d("📢 Status de la room ${event.roomId} mis à jour: ${status}");

          if (status.isPlaying) {
            // ✅ On envoie la room actuelle dans le nouvel état
            return RoomState.gameStarted(state.currentRoom!);
          } else {
            return state;
          }
        },
        onError: (error, _) {
          logger.e("❌ Erreur stream du status ${event.roomId}", error: error);
          return RoomState.error("Erreur stream status: ${error.toString()}");
        },
      );
    } catch (e) {
      logger.e("❌ Erreur dans le stream du status de ${event.roomId}", error: e);
      emit(RoomState.error("Erreur stream status: ${e.toString()}"));
    }
  }


  Future<void> _onStartGame(StartGameEvent event, Emitter<RoomState> emit) async{
    try{
      logger.i("▶️ Démarrage du jeu dans la room ${event.roomId}");
      await roomRepository.startGame(event.roomId);
      logger.i("✅ Jeu démarré dans la room ${event.roomId}");
    }catch(e){
      logger.e("❌ Erreur lors du démarrage du jeu dans la room ${event.roomId}", error: e);
      emit(RoomState.error("Erreur démarrage jeu: ${e.toString()}"));
    }
  }

}
