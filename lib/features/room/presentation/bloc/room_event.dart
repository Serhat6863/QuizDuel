import 'package:equatable/equatable.dart';
import 'package:quizduel/features/auth/domain/entity/user_entity.dart';
import 'package:quizduel/features/room/domain/entitiy/room_entity.dart';

abstract class RoomEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateRoomEvent extends RoomEvent {
  final RoomEntity roomEntity;
  CreateRoomEvent({required this.roomEntity});

  @override
  List<Object?> get props => [roomEntity];
}

class JoinRoomEvent extends RoomEvent {
  final String roomId;
  final UserEntity userEntity;
  JoinRoomEvent({required this.roomId, required this.userEntity});

  @override
  List<Object?> get props => [roomId, userEntity];
}

class LeaveRoomEvent extends RoomEvent {
  final String roomId;
  final UserEntity userEntity;
  LeaveRoomEvent({required this.roomId, required this.userEntity});

  @override
  List<Object?> get props => [roomId, userEntity];
}

class DeleteRoomEvent extends RoomEvent {
  final String roomId;
  DeleteRoomEvent({required this.roomId});

  @override
  List<Object?> get props => [roomId];
}

class FetchAvailableRoomsEvent extends RoomEvent {}

/// 🔥 Nouveau : écouter une room en temps réel
class ListenRoomEvent extends RoomEvent {
  final String roomId;
  ListenRoomEvent({required this.roomId});

  @override
  List<Object?> get props => [roomId];
}
