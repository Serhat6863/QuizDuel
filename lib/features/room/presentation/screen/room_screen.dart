import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizduel/features/room/domain/entitiy/room_entity.dart';
import 'package:quizduel/features/room/presentation/bloc/room_bloc.dart';
import 'package:quizduel/features/room/presentation/bloc/room_event.dart';

class RoomScreen extends StatefulWidget {

  final RoomEntity roomEntity;

  const RoomScreen({super.key, required this.roomEntity});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Room: ${widget.roomEntity.roomName}' , style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,

      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text('Room ID: ${widget.roomEntity.roomId}'),


            const SizedBox(height: 20,),
            ElevatedButton(
              onPressed: (){
                if(widget.roomEntity.isHost){
                  context.read<RoomBloc>().add(DeleteRoomEvent(roomId: widget.roomEntity.roomId));
                  Navigator.of(context).pop();
                }
              },
              child: Text('Delete Room'),
            )
          ],
        ),
      ),
    );
  }
}
