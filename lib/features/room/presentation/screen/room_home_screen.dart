import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizduel/features/room/presentation/bloc/room_bloc.dart';
import 'package:quizduel/features/room/presentation/screen/room_list_screen.dart';
import 'package:quizduel/features/room/presentation/screen/room_screen.dart';
import 'package:quizduel/features/room/presentation/widget/custom_card_widget.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/screen/login_screen.dart';
import '../../domain/entitiy/room_entity.dart';
import '../bloc/room_event.dart';
import '../bloc/room_state.dart';

class RoomHomeScreen extends StatefulWidget {
  const RoomHomeScreen({super.key});

  @override
  State<RoomHomeScreen> createState() => _RoomHomeScreenState();
}

class _RoomHomeScreenState extends State<RoomHomeScreen> {
  final TextEditingController _roomNameController = TextEditingController();
  final TextEditingController _joinCodeController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _roomNameController.dispose();
    _joinCodeController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status.isUnauthenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      },

      child: Scaffold(
        backgroundColor: Colors.grey.shade100, // fond clair
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () => context.read<AuthBloc>().add(LoggedOut()),
              icon: const Icon(Icons.logout, color: Colors.white),
            ),
          ],
          title: Text(
            "QuizDuel",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.deepPurple,
          elevation: 4,
        ),
        body: BlocConsumer<RoomBloc, RoomState>(
          listener: (context, state) {
            if (state.status.isRoomCreated && state.currentRoom != null) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      RoomScreen(roomEntity: state.currentRoom!),
                ),
              );
            } else if (state.status.isError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'An error occurred'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: CustomCardWidget(
                      title: "Create room",
                      subtitle: "Create a new room",
                      iconData: Icons.edit,
                      buttonText: Text(
                        "Create Room",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      buttonColor: Colors.blue,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Create Room"),
                              content: Form(
                                key: formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextFormField(
                                      controller: _roomNameController,
                                      decoration: const InputDecoration(
                                        hintText: "Enter room name",
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Please enter a room name";
                                        }else if(value.length > 6){
                                          return "Room name must be at most 6 characters";
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    TextFormField(
                                      controller: _joinCodeController,
                                      decoration: const InputDecoration(
                                        hintText: "Enter join code",
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Please enter a join code";
                                        }else if(value.length > 4){
                                          return "Join code must be at most 4 characters";
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),

                                    ElevatedButton(
                                      onPressed: () {
                                        final authState = context.read<AuthBloc>().state;

                                        if (formKey.currentState!.validate() && authState.user != null) {
                                          // 1. Dispatch l'événement
                                          context.read<RoomBloc>().add(
                                            CreateRoomEvent(
                                              roomEntity: RoomEntity(
                                                roomId: '',
                                                roomName: _roomNameController.text,
                                                hostId: authState.user!.id,
                                                userId: [authState.user!.id],
                                                maxPlayers: 4,
                                                createdAt: DateTime.now(),
                                                status: "waiting",
                                                joinCode: _joinCodeController.text,
                                                quizId: "",
                                                isHost: true,
                                              ),
                                            ),
                                          );

                                          // 2. Fermer le dialog
                                          Navigator.pop(context);
                                        }
                                      },
                                      child: state.status.isLoading
                                          ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.black87,
                                              strokeWidth: 2,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Text("Creating..."),
                                        ],
                                      )
                                          : const Text(
                                        "Create",
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                            );
                          },
                        );
              
                      },
                    ),
                  ),
              
                  const SizedBox(height: 15),
              
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: CustomCardWidget(
                      title: "See available rooms",
                      subtitle: "Enter a existing room",
                      iconData: Icons.group_add,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const RoomListScreen(),
                          ),
                        );
                      },
                      buttonText: Text(
                        "See Rooms",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      buttonColor: Colors.green,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
