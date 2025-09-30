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
      // 1. Join the room
      await roomRepository.joinRoom(event.roomId, event.userEntity);

      // 2. Fetch the updated room details
      final rooms = await roomRepository.getAvailableRooms();
      final joinsRoom = rooms.firstWhere((r) => r.roomId == event.roomId);

      // 3. Emit the updated room state
      emit(RoomState.roomCreated(joinsRoom));
    } catch (e) {
      emit(RoomState.error(e.toString()));
    }
  }

  Future<void> _onLeaveRoom(
    LeaveRoomEvent event,
    Emitter<RoomState> emit,
  ) async {
    emit(RoomState.loading());
    try {
      // 1. Leave the room
      await roomRepository.leaveRoom(event.roomId, event.userEntity);

      // 2. Fetch the updated list of available rooms
      final rooms = await roomRepository.getAvailableRooms();

      // 3. Emit the updated rooms state
      emit(RoomState.roomLoaded(rooms));
    } catch (e) {
      emit(RoomState.error(e.toString()));
    }
  }

  Future<void> _onDeleteRoom(
    DeleteRoomEvent event,
    Emitter<RoomState> emit,
  ) async {
    emit(RoomState.loading());
    try {
      // 1. Delete the room
      await roomRepository.deleteRoom(event.roomId);

      // 2. Fetch the updated list of available rooms
      final rooms = await roomRepository.getAvailableRooms();

      // 3. Emit the updated rooms state
      emit(RoomState.roomLoaded(rooms));
    } catch (e) {
      emit(RoomState.error(e.toString()));
    }
  }

  Future<void> _onFetchAvailableRooms(
    FetchAvailableRoomsEvent event,
    Emitter<RoomState> emit,
  ) async {
    emit(RoomState.loading());
    try {
      // 1. Fetch the available rooms
      final rooms = await roomRepository.getAvailableRooms();

      // 2. Emit the loaded rooms state
      emit(RoomState.roomLoaded(rooms));
    } catch (e) {
      emit(RoomState.error(e.toString()));
    }
  }


}
