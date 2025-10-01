import 'package:bloc/bloc.dart';
import 'package:quizduel/features/auth/domain/repository/user_repository.dart';
import 'package:quizduel/features/room/domain/repository/room_repository.dart';
import 'package:quizduel/features/room/presentation/bloc/room_event.dart';
import 'package:quizduel/features/room/presentation/bloc/room_state.dart';

class RoomBloc extends Bloc<RoomEvent, RoomState> {
  final RoomRepository roomRepository;
  final UserRepository userRepository;

  RoomBloc({required this.roomRepository, required this.userRepository})
      : super(RoomState.initial()) {
    on<CreateRoomEvent>(_onCreateRoom);
    on<JoinRoomEvent>(_onJoinRoom);
    on<LeaveRoomEvent>(_onLeaveRoom);
    on<DeleteRoomEvent>(_onDeleteRoom);
    on<FetchAvailableRoomsEvent>(_onFetchAvailableRooms);

    /// 🔥 écoute temps réel
    on<ListenRoomEvent>(_onListenRoom);
  }

  Future<void> _onCreateRoom(
      CreateRoomEvent event,
      Emitter<RoomState> emit,
      ) async {
    emit(RoomState.loading());
    try {
      // 1. Create the room
      final room = await roomRepository.createRoom(event.roomEntity);

      if (room != null) {
        // 2. Vérifie si le créateur est bien l’host
        final currentUser = await userRepository.getCurrentUser();
        if (currentUser != null && room.hostId == currentUser.id) {
          await roomRepository.autoDeleteRoom(room.roomId);
        }

        emit(RoomState.roomCreated(room));
      } else {
        emit(RoomState.error("Failed to create room"));
      }
    } catch (e) {
      emit(RoomState.error(e.toString()));
    }
  }

  Future<void> _onJoinRoom(JoinRoomEvent event, Emitter<RoomState> emit) async {
    emit(RoomState.loading());
    try {
      // 1. On ajoute l'utilisateur
      await roomRepository.joinRoom(event.roomId, event.userEntity);

      // 2. On commence à écouter la room en temps réel
      add(ListenRoomEvent(roomId: event.roomId));
    } catch (e) {
      emit(RoomState.error(e.toString()));
    }
  }


  Future<void> _onLeaveRoom(
      LeaveRoomEvent event, Emitter<RoomState> emit) async {
    emit(RoomState.loading());
    try {
      await roomRepository.leaveRoom(event.roomId, event.userEntity);
      final rooms = await roomRepository.getAvailableRooms();
      emit(RoomState.roomLoaded(rooms));
    } catch (e) {
      emit(RoomState.error(e.toString()));
    }
  }

  Future<void> _onDeleteRoom(
      DeleteRoomEvent event, Emitter<RoomState> emit) async {
    emit(RoomState.loading());
    try {
      await roomRepository.deleteRoom(event.roomId);
      final rooms = await roomRepository.getAvailableRooms();
      emit(RoomState.roomLoaded(rooms));
    } catch (e) {
      emit(RoomState.error(e.toString()));
    }
  }

  Future<void> _onFetchAvailableRooms(
      FetchAvailableRoomsEvent event, Emitter<RoomState> emit) async {
    emit(RoomState.loading());
    try {
      final rooms = await roomRepository.getAvailableRooms();
      emit(RoomState.roomLoaded(rooms));
    } catch (e) {
      emit(RoomState.error(e.toString()));
    }
  }

  /// 🔥 gestion du stream temps réel
  Future<void> _onListenRoom(
      ListenRoomEvent event, Emitter<RoomState> emit) async {
    await emit.forEach(
      roomRepository.roomStream(event.roomId),
      onData: (room) => RoomState.roomCreated(room),
      onError: (error, _) => RoomState.error(error.toString()),
    );
  }
}
