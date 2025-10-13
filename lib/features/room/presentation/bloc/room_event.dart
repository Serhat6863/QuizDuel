import 'package:equatable/equatable.dart';
import 'package:quizduel/features/auth/domain/entity/user_entity.dart';
import 'package:quizduel/features/room/domain/entitiy/room_entity.dart';

abstract class RoomEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// 🔹 Création d’une room
class CreateRoomEvent extends RoomEvent {
  final RoomEntity roomEntity;
  CreateRoomEvent({required this.roomEntity});

  @override
  List<Object?> get props => [roomEntity];
}

// 🔹 Rejoindre une room
class JoinRoomEvent extends RoomEvent {
  final String roomId;
  final UserEntity userEntity;
  JoinRoomEvent({required this.roomId, required this.userEntity});

  @override
  List<Object?> get props => [roomId, userEntity];
}

// 🔹 Quitter une room
class LeaveRoomEvent extends RoomEvent {
  final String roomId;
  final UserEntity userEntity;
  LeaveRoomEvent({required this.roomId, required this.userEntity});

  @override
  List<Object?> get props => [roomId, userEntity];
}

// 🔹 Supprimer une room (host seulement)
class DeleteRoomEvent extends RoomEvent {
  final String roomId;
  DeleteRoomEvent({required this.roomId});

  @override
  List<Object?> get props => [roomId];
}

// 🔹 Charger toutes les rooms disponibles
class FetchAvailableRoomsEvent extends RoomEvent {}

// 🔹 Écouter en temps réel une room spécifique
class ListenRoomEvent extends RoomEvent {
  final String roomId;
  ListenRoomEvent({required this.roomId});

  @override
  List<Object?> get props => [roomId];
}


class ListenPlayersEvent extends RoomEvent {
  final String roomId;
  ListenPlayersEvent({required this.roomId});

  @override
  List<Object?> get props => [roomId];
}

class ListenStatusEvent extends RoomEvent {
  final String roomId;
  ListenStatusEvent({required this.roomId});

  @override
  List<Object?> get props => [roomId];
}


class StartGameEvent extends RoomEvent {
  final String roomId;
  StartGameEvent({required this.roomId});

  @override
  List<Object?> get props => [roomId];
}


class UpdateFinalScoreEvent extends RoomEvent{
  final String roomId;
  final String userId;
  final int newScore;

  UpdateFinalScoreEvent({
    required this.roomId,
    required this.userId,
    required this.newScore,
  });

  @override
  List<Object?> get props => [roomId, userId, newScore];
}

class GetRoomByIdEvent extends RoomEvent{
  final String roomId;

  GetRoomByIdEvent({required this.roomId});

  @override
  List<Object?> get props => [roomId];
}


