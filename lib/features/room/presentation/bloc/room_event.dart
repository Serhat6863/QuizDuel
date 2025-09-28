import 'package:equatable/equatable.dart';
import 'package:quizduel/features/room/domain/entitiy/room_entity.dart';

abstract class RoomEvent extends Equatable{
  @override
  List<Object?> get props => [];
}


class CreateRoomEvent extends RoomEvent{
  final RoomEntity roomEntity;

  CreateRoomEvent({
    required this.roomEntity
  });

  @override
  List<Object?> get props => [roomEntity];
}


class JoinRoomEvent extends RoomEvent{
  final String roomId;
  final String userId;

  JoinRoomEvent({
    required this.roomId,
    required this.userId,
  });

  @override
  List<Object?> get props => [roomId, userId];
}

class LeaveRoomEvent extends RoomEvent{
  final String roomId;
  final String userId;

  LeaveRoomEvent({
    required this.roomId,
    required this.userId,
  });

  @override
  List<Object?> get props => [roomId, userId];
}

class DeleteRoomEvent extends RoomEvent{
  final String roomId;

  DeleteRoomEvent({
    required this.roomId,
  });

  @override
  List<Object?> get props => [roomId];
}

class FetchAvailableRoomsEvent extends RoomEvent{
  FetchAvailableRoomsEvent();

  @override
  List<Object?> get props => [];
}

class ListRoomEvent extends RoomEvent{
  final String roomId;

  ListRoomEvent({
    required this.roomId,
  });

  @override
  List<Object?> get props => [roomId];
}