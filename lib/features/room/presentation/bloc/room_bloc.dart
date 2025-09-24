import 'package:bloc/bloc.dart';
import 'package:quizduel/features/room/domain/repository/room_repository.dart';
import 'package:quizduel/features/room/presentation/bloc/room_event.dart';
import 'package:quizduel/features/room/presentation/bloc/room_state.dart';

class RoomBloc extends Bloc<RoomEvent, RoomState>{

  final RoomRepository roomRepository;

  RoomBloc({required this.roomRepository}) : super(RoomState.initial()){
    on<CreateRoomEvent>(_onCreateRoom);
    on<JoinRoomEvent>(_onJoinRoom);
    on<LeaveRoomEvent>(_onLeaveRoom);
    on<DeleteRoomEvent>(_onDeleteRoom);
    on<FetchAvailableRoomsEvent>(_onFetchAvailableRooms);
  }





}