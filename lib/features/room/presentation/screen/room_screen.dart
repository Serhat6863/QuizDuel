import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizduel/features/room/domain/entitiy/room_entity.dart';
import 'package:quizduel/features/room/presentation/bloc/room_bloc.dart';
import 'package:quizduel/features/room/presentation/bloc/room_event.dart';

import '../bloc/room_state.dart';

class RoomScreen extends StatefulWidget {
  final RoomEntity roomEntity;

  const RoomScreen({super.key, required this.roomEntity});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.roomEntity.roomName),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Room Name : ${widget.roomEntity.roomName}" , style: TextStyle(fontSize: 20),),
            Text("Room Id : ${widget.roomEntity.user[0].username}" , style: TextStyle(fontSize: 20),),

            const SizedBox(height: 20,),



            if(widget.roomEntity.isHost)
              ElevatedButton(
                onPressed: (){
                  context.read<RoomBloc>().add(DeleteRoomEvent(roomId: widget.roomEntity.roomId));
                  Navigator.of(context).pop();
                },
                child: Text("Leave Room"),
              )


          ],
        ),
      ),


    );
  }
}
