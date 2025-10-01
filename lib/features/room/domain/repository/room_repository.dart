import 'package:quizduel/features/auth/domain/entity/user_entity.dart';
import 'package:quizduel/features/room/domain/entitiy/room_entity.dart';

abstract class RoomRepository{
  Future<RoomEntity?> createRoom(RoomEntity room);
  Future<void> joinRoom(String roomId , UserEntity user);
  Future<void> leaveRoom(String roomId , UserEntity user);
  Future<void> deleteRoom(String roomId);
  Future <List<RoomEntity>> getAvailableRooms();
  Stream<RoomEntity> roomStream(String roomId);
  Future<void> autoDeleteRoom(String roomId);
}