import 'package:quizduel/features/auth/domain/entity/user_entity.dart';
import 'package:quizduel/features/room/domain/entitiy/room_entity.dart';

enum RoomStatus {
  initial,

  // 👇 On sépare les loadings
  loadingRooms,     // quand on fetch la liste des rooms
  creatingRoom,     // quand on crée une room
  joiningRoom,      // quand on rejoint une room
  gameLoading,     // quand on charge la game (quiz)

  loaded,           // rooms chargées
  roomCreated,      // room créée
  gameStarted,
  playersUpdated,
  deleted,
  error,
}

extension RoomStatusX on RoomStatus {
  bool get isInitial => this == RoomStatus.initial;
  bool get isLoadingRooms => this == RoomStatus.loadingRooms;
  bool get isCreatingRoom => this == RoomStatus.creatingRoom;
  bool get isJoiningRoom => this == RoomStatus.joiningRoom;
  bool get isGameLoading => this == RoomStatus.gameLoading;

  bool get isLoaded => this == RoomStatus.loaded;
  bool get isRoomCreated => this == RoomStatus.roomCreated;
  bool get isGameStarted => this == RoomStatus.gameStarted;
  bool get isPlayersUpdated => this == RoomStatus.playersUpdated;
  bool get isDeleted => this == RoomStatus.deleted;
  bool get isError => this == RoomStatus.error;
}

class RoomState {
  final RoomStatus status;
  final String? errorMessage;
  final List<RoomEntity> availableRooms;
  final RoomEntity? currentRoom;
  final List<UserEntity>? players;

  const RoomState({
    required this.status,
    this.errorMessage,
    this.availableRooms = const [],
    this.currentRoom,
    this.players,
  });

  // 🔹 états de base
  factory RoomState.initial() => const RoomState(status: RoomStatus.initial);

  // 🔹 rooms disponibles (liste)
  factory RoomState.loadingRooms() =>
      const RoomState(status: RoomStatus.loadingRooms);

  factory RoomState.creatingRoom() =>
      const RoomState(status: RoomStatus.creatingRoom);

  factory RoomState.joiningRoom() =>
      const RoomState(status: RoomStatus.joiningRoom);

  factory RoomState.gameLoading(RoomEntity room) => RoomState(
    status: RoomStatus.gameLoading,
    currentRoom: room,
  );

  factory RoomState.roomLoaded(List<RoomEntity> rooms) => RoomState(
    status: RoomStatus.loaded,
    availableRooms: rooms,
  );

  // 🔹 room en cours
  factory RoomState.roomCreated(RoomEntity room) => RoomState(
    status: RoomStatus.roomCreated,
    currentRoom: room,
  );



  factory RoomState.gameStarted() => const RoomState(status: RoomStatus.gameStarted);



  factory RoomState.roomDeleted() =>
      const RoomState(status: RoomStatus.deleted);

  factory RoomState.roomLeft() => const RoomState(status: RoomStatus.initial);

  factory RoomState.playersUpdated(List<UserEntity> players) => RoomState(
    status: RoomStatus.playersUpdated,
    players: players,
  );

  factory RoomState.error(String message) => RoomState(
    status: RoomStatus.error,
    errorMessage: message,
  );

  RoomState copyWith({
    RoomStatus? status,
    String? errorMessage,
    List<RoomEntity>? availableRooms,
    RoomEntity? currentRoom,
    List<UserEntity>? players,
  }) {
    return RoomState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      availableRooms: availableRooms ?? this.availableRooms,
      currentRoom: currentRoom ?? this.currentRoom,
      players: players ?? this.players,
    );
  }
}
