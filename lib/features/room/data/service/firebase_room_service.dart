import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/room_model.dart';

class FirebaseRoomService{


  FirebaseFirestore firestore = FirebaseFirestore.instance;


  // create room
  Future<RoomModel?> createRoom(RoomModel room) async {
    try{
      final docRef = await firestore.collection("rooms").add({
        ...room.toJson(),
        "hostId": room.hostId,
        "userId": [room.hostId],
        "roomName": room.roomName,
        "isHost": true,
        "createdAt" : DateTime.now().toIso8601String(),
      });

      final doc = await docRef.get();

      return RoomModel.fromJson(doc.data() as Map<String ,dynamic>);

    }catch(e){
      throw Exception(e);
    }
  }

  // delete room
  Future<void> deleteRoom(String roomId) async {
    try{
      await firestore.collection("rooms").doc(roomId).delete();
    }catch(e){
      throw Exception(e);
    }
  }

  // join room
  Future<void> joinRoom(String roomId , String userId) async {
    try{
      final docRef = firestore.collection("rooms").doc(roomId);
      final doc = await docRef.get();

      if(doc.exists){
        final room = RoomModel.fromJson(doc.data() as Map<String ,dynamic>);
        if(room.userId.length < room.maxPlayers){
          room.userId.add(userId);
          await docRef.update({
            "userId": FieldValue.arrayUnion([userId]),
            "isHost": false,
          });
        }else{
          throw Exception("Room is full");
        }
      }
    }catch(e){
      throw Exception(e);
    }
  }


  // leave room
  Future<void> leaveRoom(String roomId , String userId) async {
    try{
      final docRef = firestore.collection("rooms").doc(roomId);
      final doc = await docRef.get();

      if(doc.exists){
        final room = RoomModel.fromJson(doc.data() as Map<String ,dynamic>);
        if(room.userId.contains(userId)){
          room.userId.remove(userId);
          await docRef.update({
            "userId": FieldValue.arrayRemove([userId]),
          });
        }else{
          throw Exception("User not in room");
        }
      }
    }catch(e){
      throw Exception(e);
    }
  }


  // get available rooms
  Future<List<RoomModel>> getAvailableRooms() async {
    try{
      final querySnapshot = await firestore.collection("rooms").get();
      final rooms = querySnapshot.docs.map((doc) => RoomModel.fromJson(doc.data())).toList();
      return rooms;
    }catch(e){
      throw Exception(e);
    }
  }






}