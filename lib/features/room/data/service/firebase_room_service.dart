import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizduel/features/auth/data/model/user_model.dart';

import '../model/room_model.dart';

class FirebaseRoomService{


  FirebaseFirestore firestore = FirebaseFirestore.instance;


  // create room
  Future<RoomModel?> createRoom(RoomModel room) async {
    try{

      // verify if room with same name exists and with same hostId
      final querySnapshot = await firestore.collection("rooms")
          .where("roomName", isEqualTo: room.roomName)
          .where("hostId", isEqualTo: room.hostId)
          .get();

      if(querySnapshot.docs.isNotEmpty){
        throw Exception("Room with same name already exists");
      }


      final userData = room.user.map((user){
        if(user is UserModel){
          return user.toJson();
        }else {
          return UserModel(
          id: user.id,
          email: user.email,
          username: user.username,
        ).toJson();
        }
      }).toList();


      final docRef = await firestore.collection("rooms").add({
        ...room.toJson(),
        "hostId": room.hostId,
        "user": userData,
        "roomName": room.roomName,
        "isHost": true,
        "createdAt" : DateTime.now().toIso8601String(),
      });

      await docRef.update({"roomId": docRef.id});

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
  Future<void> joinRoom(String roomId , UserModel user) async {
    try{
      final docRef = firestore.collection("rooms").doc(roomId);
      final doc = await docRef.get();

      if(doc.exists){
        final room = RoomModel.fromJson(doc.data() as Map<String ,dynamic>);
        if(room.user.length < room.maxPlayers){
          room.user.add(user);
          await docRef.update({
            "user": FieldValue.arrayUnion([user]),
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
  Future<void> leaveRoom(String roomId , UserModel user) async {
    try{
      final docRef = firestore.collection("rooms").doc(roomId);
      final doc = await docRef.get();

      if(doc.exists){
        final room = RoomModel.fromJson(doc.data() as Map<String ,dynamic>);
        if(room.user.contains(user)){
          room.user.remove(user);
          await docRef.update({
            "userId": FieldValue.arrayRemove([user]),
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

  // room stream
  Stream<RoomModel> roomStream(String roomId){
    try{
      final docRef = firestore.collection("rooms").doc(roomId);

      return docRef.snapshots().map((docRef){
        if(docRef.exists){
          return RoomModel.fromJson(docRef.data() as Map<String ,dynamic>);
        }else{
          throw Exception("Room not found");
        }
      });
    }catch(e){
      throw Exception(e);
    }

  }







}