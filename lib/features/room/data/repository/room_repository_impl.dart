import 'package:quizduel/features/auth/data/model/user_model.dart';
import 'package:quizduel/features/auth/domain/entity/user_entity.dart';
import 'package:quizduel/features/room/data/model/room_model.dart';
import 'package:quizduel/features/room/data/service/firebase_room_service.dart';
import 'package:quizduel/features/room/domain/entitiy/room_entity.dart';
import 'package:quizduel/features/room/domain/repository/room_repository.dart';


class RoomRepositoryImpl implements RoomRepository{

  final FirebaseRoomService firebaseRoomService;

  RoomRepositoryImpl({required this.firebaseRoomService});


  @override
  Future<RoomEntity?> createRoom(RoomEntity room) async{
    try{
      final roomModel = RoomModel(
        roomId: room.roomId,
        roomName: room.roomName,
        hostId: room.hostId,
        user: room.user,
        status: room.status,
        joinCode: room.joinCode,
        createdAt: room.createdAt,
        maxPlayers: room.maxPlayers,
        quizId: room.quizId,

      );

      final createdRoom = await firebaseRoomService.createRoom(roomModel)
      .timeout(const Duration(seconds: 30), onTimeout: (){
        throw Exception("Room creation timed out");
      });

      return createdRoom?.toEntity();

    }catch(e){
      throw Exception("Something went wrong while creating room: ${e.toString()}");
    }
  }

  @override
  Future<void> deleteRoom(String roomId) async{
    try{
      await firebaseRoomService.deleteRoom(roomId);
    }catch(e){
      throw Exception("Something went wrong while deleting room: ${e.toString()}");
    }

  }

  @override
  Future<List<RoomEntity>> getAvailableRooms() async{
    try{
      final rooms = await firebaseRoomService.getAvailableRooms();
      return rooms.map((room) => room.toEntity()).toList();
    }catch(e){
      throw Exception("Something went wrong while fetching available rooms: ${e.toString()}");
    }
  }

  @override
  Future<void> joinRoom(String roomId, UserEntity user) async{
    try{

      final userModel = UserModel(
        id: user.id,
        email: user.email,
        username: user.username,
      );

      await firebaseRoomService.joinRoom(roomId, userModel);
    }catch(e){
      throw Exception("Something went wrong while joining room: ${e.toString()}");
    }
  }

  @override
  Future<void> leaveRoom(String roomId, UserEntity user) async{
    try{

      final userModel = UserModel(
        id: user.id,
        email: user.email,
        username: user.username,
      );


      await firebaseRoomService.leaveRoom(roomId, userModel);
    }catch(e){
      throw Exception("Something went wrong while leaving room: ${e.toString()}");
    }
  }

  @override
  Stream<RoomEntity> roomStream(String roomId) {
    try{
      return firebaseRoomService.roomStream(roomId).map((roomModel) => roomModel.toEntity());
    }catch(e){
      throw Exception("Something went wrong while streaming room: ${e.toString()}");
    }
  }

  @override
  Future<void> autoDeleteRoom(String roomId) async{
    try{
      await firebaseRoomService.setAutoDeleteOndiconnect(roomId);

    }catch(e){
      throw Exception("Something went wrong while setting up auto delete for room: ${e.toString()}");
    }
  }

}