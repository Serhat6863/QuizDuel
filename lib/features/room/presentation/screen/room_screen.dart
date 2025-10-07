import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizduel/features/game/presentation/screen/game_screen.dart';
import 'package:quizduel/features/room/domain/entitiy/room_entity.dart';
import 'package:quizduel/features/room/presentation/bloc/room_event.dart';
import 'package:quizduel/features/room/presentation/bloc/room_state.dart';
import 'package:quizduel/features/room/presentation/screen/room_home_screen.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/room_bloc.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key, required this.roomEntity});

  final RoomEntity roomEntity;

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  @override
  void initState() {
    super.initState();
    // 🔥 Dès qu’on ouvre la room → on écoute les joueurs
    context.read<RoomBloc>().add(
      ListenPlayersEvent(roomId: widget.roomEntity.roomId),
    );
    // 🔥 Dès qu’on ouvre la room → on écoute le status
    context.read<RoomBloc>().add(
      ListenStatusEvent(roomId: widget.roomEntity.roomId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthBloc>().state.user;

    return BlocListener<RoomBloc, RoomState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == RoomStatus.deleted) {
          final snackBar = SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Room Deleted',
              message: 'The room has been successfully deleted.',
              contentType: ContentType.success,
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          Navigator.pop(context);
        } else if (state.status == RoomStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? "Erreur inconnue")),
          );
        }else if(state.status == RoomStatus.initial){
          final snackBar = SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Room leave',
              message: "You have left the room.",
              contentType: ContentType.success,
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          Navigator.push(
            context,
            MaterialPageRoute(builder : (context) => const HomeScreen()),
          );
        }else if(state.status == RoomStatus.gameStarted){
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder : (context) =>  GameScreen(roomEntity: widget.roomEntity)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5E6C4),
        body: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 50, bottom: 20),
              decoration: BoxDecoration(
                color: Colors.green.shade600,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Center(
                child: Text(
                  "Room: ${widget.roomEntity.roomName}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 BlocBuilder qui affiche les joueurs
            Expanded(
              child: BlocBuilder<RoomBloc, RoomState>(
                buildWhen: (prev, curr) => prev.players != curr.players,
                builder: (context, state) {
                  final players = state.players ?? [];

                  return Column(
                    children: [
                      Text(
                        "Players (${players.length}/${widget.roomEntity.maxPlayers})",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          itemCount: players.length,
                          itemBuilder: (context, index) {
                            final player = players[index];
                            final isPlayerHost =
                                player.id == widget.roomEntity.hostId;

                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isPlayerHost
                                      ? Colors.amber.shade700
                                      : Colors.grey.shade400,
                                  child: Icon(
                                    isPlayerHost ? Icons.star : Icons.person,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(player.username),
                                subtitle: isPlayerHost
                                    ? const Text(
                                        "Host 👑",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Boutons du host
            if (currentUser != null &&
                widget.roomEntity.hostId == currentUser.id) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                  label: const Text(
                    "Start the Game",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  onPressed: () {
                    context.read<RoomBloc>().add(
                          StartGameEvent(roomId: widget.roomEntity.roomId),
                        );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.delete, color: Colors.white),
                  label: const Text(
                    "Delete Room",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  onPressed: () {
                    _showDeleteConfirmationDialog(
                      context,
                      widget.roomEntity.roomId,
                    );
                  },
                ),
              ),
            ],
            // Bouton Leave pour les autres joueurs
            if (currentUser != null &&
                widget.roomEntity.hostId != currentUser.id) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.exit_to_app, color: Colors.white),
                  label: const Text(
                    "Leave Room",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  onPressed: () {
                    context.read<RoomBloc>().add(
                      LeaveRoomEvent(
                        roomId: widget.roomEntity.roomId,
                        userEntity: currentUser,
                      ),
                    );
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String roomId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Room"),
          content: const Text("Are you sure you want to delete this room?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<RoomBloc>().add(DeleteRoomEvent(roomId: roomId));
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}
