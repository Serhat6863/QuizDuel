import 'package:quizduel/features/auth/data/model/user_model.dart';
import 'package:firebase_database/firebase_database.dart';

import '../model/room_model.dart';

class FirebaseRoomService{

  final DatabaseReference db = FirebaseDatabase.instance.ref();


  //create room
  // create room
  Future<RoomModel?> createRoom(RoomModel room) async {
    try {
      final roomRef = db.child("rooms").push();

      print("avant set()");

      // 👇 On stocke les users en Map, clé = userId
      final Map<String, dynamic> userData = {
        for (var u in room.user)
          u.id: (u is UserModel
              ? u.toJson()
              : UserModel(
            id: u.id,
            email: u.email,
            username: u.username,
          ).toJson())
      };

      final roomData = {
        ...room.toJson(),
        "roomId": roomRef.key,
        "user": userData, // 👈 Map au lieu de List
        "isHost": true,
        "createdAt": DateTime.now().toIso8601String(),
      };

      await roomRef.set(roomData);

      print("après set()");

      return RoomModel.fromJson(roomData);
    } catch (e) {
      print(e.toString());
      throw Exception(e);
    }
  }





  Future<void> setAutoDeleteOndiconnect(String roomId) async{
    try{
      final roomRef = db.child("rooms/$roomId");
      await roomRef.onDisconnect().remove();
    }catch(e){
      throw Exception(e);
    }
  }

  // delete room
  Future<void> deleteRoom(String roomId) async {
    try {
      await db.child("rooms/$roomId").remove();
    } catch (e) {
      print(e.toString());
      throw Exception(e);
    }
  }


  //join room
  Future<void> joinRoom(String roomId , UserModel user) async{
    try{
      final userRef = db.child("rooms/$roomId/user/${user.id}");
      await userRef.set(user.toJson());
    }catch(e){
      print(e.toString());
      throw Exception(e);
    }
  }

  Future<void> leaveRoom(String roomId, UserModel user) async {
    try {
      final userRef = db.child("rooms/$roomId/user/${user.id}");
      await userRef.remove();
    } catch (e) {
      throw Exception(e);
    }
  }

  // get available rooms
  Future<List<RoomModel>> getAvailableRooms() async {
    try {
      final snapshot = await db.child("rooms").get();

      if (snapshot.exists && snapshot.value is Map) {
        final rawMap = snapshot.value as Map<Object?, Object?>;

        final rooms = rawMap.entries.map((entry) {
          final roomData = deepCast(entry.value as Map);
          return RoomModel.fromJson(roomData);
        }).toList();

        return rooms;
      }
      return [];
    } catch (e) {
      throw Exception("Error while fetching rooms: $e");
    }
  }

  // Deep cast function to convert Map<Object?, Object?> to Map<String, dynamic>
  Map<String, dynamic> deepCast(Map input) {
    return input.map((key, value) {
      if (value is Map) {
        return MapEntry(key.toString(), deepCast(value));
      } else if (value is List) {
        return MapEntry(
          key.toString(),
          value.map((e) => e is Map ? deepCast(e) : e).toList(),
        );
      } else {
        return MapEntry(key.toString(), value);
      }
    });
  }



  // room stream
  Stream<RoomModel> roomStream(String roomId) {
    final roomRef = db.child("rooms/$roomId");
    return roomRef.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        return RoomModel.fromJson(Map<String, dynamic>.from(data));
      } else {
        throw Exception("Room not found");
      }
    });
  }





}