import 'package:quizduel/features/room/domain/entitiy/room_entity.dart';

enum RoomStatus { initial, loading, loaded, error }

extension RoomStatusX on RoomStatus {
  bool get isInitial => this == RoomStatus.initial;
  bool get isLoading => this == RoomStatus.loading;
  bool get isLoaded => this == RoomStatus.loaded;
  bool get isError => this == RoomStatus.error;
}


class RoomState{
  final RoomStatus status;
  final String? errorMessage;
  final List<RoomEntity>? availableRooms;
  final RoomEntity? currentRoom;

  RoomState({
    required this.status,
    this.errorMessage,
    this.availableRooms,
    this.currentRoom,
  });


  factory RoomState.initial() => RoomState(
    status: RoomStatus.initial,
  );

  factory RoomState.loading() => RoomState(
    status: RoomStatus.loading,
  );

  factory RoomState.error(String message) => RoomState(
    status: RoomStatus.error,
    errorMessage: message,
  );



  factory RoomState.roomLoaded(List<RoomEntity> rooms) => RoomState(
    status: RoomStatus.loaded,
    availableRooms: rooms,
  );


  factory RoomState.roomCreated(RoomEntity room) => RoomState(
    status: RoomStatus.loaded,
    currentRoom: room,
  );


  RoomState copyWith({
    RoomStatus? status,
    String? errorMessage,
    List<RoomEntity>? availableRooms,
    RoomEntity? currentRoom,
  }) {
    return RoomState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      availableRooms: availableRooms ?? this.availableRooms,
      currentRoom: currentRoom ?? this.currentRoom,
    );
  }
}