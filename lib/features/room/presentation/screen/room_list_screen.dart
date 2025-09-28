import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizduel/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quizduel/features/room/presentation/bloc/room_bloc.dart';

import '../bloc/room_event.dart';
import '../bloc/room_state.dart';

class RoomListScreen extends StatefulWidget {
  const RoomListScreen({super.key});

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {


  Future<void> _onRefresh() async {
    context.read<RoomBloc>().add(FetchAvailableRoomsEvent());
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: const Text(
          "Available Rooms",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          onPressed: (){
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white,),
        ),
      ),
      body: BlocBuilder<RoomBloc, RoomState>(
        builder: (context, state) {
          if (state.status.isLoaded) {
            return Column(
              children: [
                RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: SizedBox(
                    height: 400,
                    child: ListView.builder(
                      itemCount: state.availableRooms?.length ?? 0,
                      itemBuilder: (context, index) {
                        final room = state.availableRooms![index];
                        final user = context.read<AuthBloc>().state.user;
                        return ListTile(
                          title: Text(room.roomName),
                          subtitle: Text(
                            'Host: ${room.hostId} - Players: ${room.userId}/${room.maxPlayers}',
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
                              // Join Room Logic
                              context.read<RoomBloc>().add(
                                JoinRoomEvent(
                                  roomId: room.roomId,
                                  userId: user!.id,
                                ),
                              );
                            },
                            child: const Text('Join'),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          } else if (state.status.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.status.isError) {
            return Center(
              child: Text(state.errorMessage ?? "Something went wrong"),
            );
          }

          return const Center(
            child: Text(
              "No Rooms Available",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          );
        },
      ),
    );
  }
}
