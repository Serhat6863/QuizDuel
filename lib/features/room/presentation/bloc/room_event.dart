import 'package:equatable/equatable.dart';

abstract class RoomEvent extends Equatable{
  @override
  List<Object?> get props => [];
}


class CreateRoomEvent extends RoomEvent{
  final String roomName;
  final String hostId;
  final int maxPlayers;

  CreateRoomEvent({
    required this.roomName,
    required this.hostId,
    required this.maxPlayers,
  });

  @override
  List<Object?> get props => [roomName, hostId, maxPlayers];
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