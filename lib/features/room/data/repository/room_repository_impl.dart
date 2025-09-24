import 'package:quizduel/features/room/data/model/room_model.dart';
import 'package:quizduel/features/room/data/service/firebase_room_service.dart';
import 'package:quizduel/features/room/domain/entitiy/room_entity.dart';
import 'package:quizduel/features/room/domain/repository/room_repository.dart';

class RoomRepositoryImpl implements RoomRepository{

  final FirebaseRoomService firebaseRoomService;

  RoomRepositoryImpl({required this.firebaseRoomService});


  @override
  Future<RoomEntity?> createRoom(RoomEntity room, String hostId) async{
    try{
      final roomModel = RoomModel(
        roomId: room.roomId,
        roomName: room.roomName,
        hostId: hostId,
        userId: room.userId,
        status: room.status,
        joinCode: room.joinCode,
        createdAt: room.createdAt,
        maxPlayers: room.maxPlayers,
        quizId: room.quizId,
      );

      final createdRoom = await firebaseRoomService.createRoom(roomModel , hostId);

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
  Future<void> joinRoom(String roomId, String userId) async{
    try{
      await firebaseRoomService.joinRoom(roomId, userId);
    }catch(e){
      throw Exception("Something went wrong while joining room: ${e.toString()}");
    }
  }

  @override
  Future<void> leaveRoom(String roomId, String userId) async{
    try{
      await firebaseRoomService.leaveRoom(roomId, userId);
    }catch(e){
      throw Exception("Something went wrong while leaving room: ${e.toString()}");
    }
  }

}