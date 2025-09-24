abstract class RoomRepository{
  Future<void> createRoom(String roomName, int maxPlayers);
  Future<void> joinRoom(String roomId);
  Future<void> leaveRoom(String roomId);
  Future<List<Map<String, dynamic>>> getAvailableRooms();
}