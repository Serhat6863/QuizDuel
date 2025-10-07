import 'package:quizduel/features/auth/domain/entity/user_entity.dart';
import 'package:quizduel/features/room/domain/entitiy/room_entity.dart';
import 'package:quizduel/features/room/domain/enums/room_game_status.dart';

abstract class RoomRepository{
  Future<RoomEntity?> createRoom(RoomEntity room);
  Future<void> joinRoom(String roomId , UserEntity user);
  Future<void> leaveRoom(String roomId , UserEntity user);
  Future<void> deleteRoom(String roomId);
  Future <List<RoomEntity>> getAvailableRooms();

  Future<void> autoDeleteRoom(String roomId);
  Stream<List<UserEntity>> playersStream(String roomId);
  Stream<RoomGameStatus> roomStatusStream(String roomId);
  Future<void> startGame(String roomId);
}