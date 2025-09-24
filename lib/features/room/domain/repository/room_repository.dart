import 'package:quizduel/features/room/domain/entitiy/room_entity.dart';

abstract class RoomRepository{
  Future<RoomEntity?> createRoom(RoomEntity room, String hostId);
  Future<void> joinRoom(String roomId , String userId);
  Future<void> leaveRoom(String roomId , String userId);
  Future<void> deleteRoom(String roomId);
  Future <List<RoomEntity>> getAvailableRooms();
}