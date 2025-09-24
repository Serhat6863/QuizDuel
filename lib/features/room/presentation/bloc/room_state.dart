import 'package:quizduel/features/room/data/model/room_model.dart';
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

  RoomState({
    required this.status,
    this.errorMessage,
    this.availableRooms,
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

  factory RoomState.loaded(List<RoomModel> rooms) => RoomState(
    status: RoomStatus.loaded,
    availableRooms: rooms,
  );


  RoomState copyWith({
    RoomStatus? status,
    String? errorMessage,
    List<RoomEntity>? availableRooms,
  }) {
    return RoomState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      availableRooms: availableRooms ?? this.availableRooms,
    );
  }
}