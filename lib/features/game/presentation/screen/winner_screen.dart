import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizduel/features/room/domain/entitiy/room_entity.dart';
import 'package:quizduel/features/room/presentation/bloc/room_bloc.dart';
import 'package:quizduel/features/room/presentation/bloc/room_event.dart';
import 'package:quizduel/features/room/presentation/bloc/room_state.dart';
import 'package:quizduel/features/room/presentation/screen/room_home_screen.dart';

class WinnerScreen extends StatefulWidget {

  final RoomEntity roomEntity;

  const WinnerScreen({super.key, required this.roomEntity});

  @override
  State<WinnerScreen> createState() => _WinnerScreenState();
}

class _WinnerScreenState extends State<WinnerScreen> {





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6C4),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            decoration: BoxDecoration(
              color: Colors.blue.shade400,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: const Center(
              child: Text(
                "QuizDuel",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const Spacer(),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events,
                size: 100,
                color: Colors.amber.shade700,
              ),
              const SizedBox(height: 10),
              Text(
                "Winner!",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),

              const SizedBox(height: 20),

              //winner + score and after second and third and fourth
              Text(
                "${widget.roomEntity.user.first.username} with ${widget.roomEntity.user.first.score} points",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 100,),


              BlocListener<RoomBloc,RoomState>(
                listener: (context, state){
                  if(state.status == RoomStatus.deleted){
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const HomeScreen())
                      , (route) => false
                    );
                  }
                },
                child: ElevatedButton(
                  onPressed: () {
                    context.read<RoomBloc>().add(DeleteRoomEvent(roomId: widget.roomEntity.roomId));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade400,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Home",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.home, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),
        ],
      ),
    );
  }
}
