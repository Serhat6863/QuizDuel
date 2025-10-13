import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizduel/core/utils/logger.dart';
import 'package:quizduel/features/room/domain/entitiy/room_entity.dart';
import 'package:quizduel/features/room/domain/enums/room_game_status.dart';
import 'package:quizduel/features/room/presentation/bloc/room_bloc.dart';
import 'package:quizduel/features/room/presentation/bloc/room_event.dart';
import 'package:quizduel/features/room/presentation/bloc/room_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import 'room_screen.dart';

class RoomListScreen extends StatefulWidget {
  const RoomListScreen({super.key});

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  bool _isDialogOpen = false;

  @override
  void initState() {
    super.initState();
    logger.i("📡 Initial loading of rooms...");
    context.read<RoomBloc>().add(FetchAvailableRoomsEvent());
  }

  Future<void> _onRefresh() async {
    logger.i("🔄 Manual refresh of room list");
    context.read<RoomBloc>().add(FetchAvailableRoomsEvent());
  }

  void _showLoadingDialog(BuildContext context, String message) {
    if (_isDialogOpen) return;
    _isDialogOpen = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.deepPurple),
              const SizedBox(height: 20),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Please wait a few seconds ⏳",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    ).then((_) => _isDialogOpen = false);
  }

  void _closeDialog(BuildContext context) {
    if (_isDialogOpen) {
      Navigator.of(context, rootNavigator: true).pop();
      _isDialogOpen = false;
    }
  }

  void _showSnackBar(String title, String message, ContentType type) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: type,
      ),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6C4),
      body: Column(
        children: [
          // 🌟 HEADER
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.amber.shade400,
                  Colors.amber.shade600,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding:
            const EdgeInsets.only(top: 50, bottom: 25, left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 🔙 Back button
                GestureDetector(
                  onTap: () {
                    logger.i("↩️ Back to previous screen");
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white30),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 22),
                  ),
                ),
                const Text(
                  "Available Rooms",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),

          // 🧩 BODY
          Expanded(
            child: BlocListener<RoomBloc, RoomState>(
              listenWhen: (prev, curr) => prev.status != curr.status,
              listener: (context, state) {
                switch (state.status) {
                  case RoomStatus.joiningRoom:
                    _showLoadingDialog(context, "Joining room...");
                    break;

                  case RoomStatus.roomCreated:
                    _closeDialog(context);
                    if (state.currentRoom != null && mounted) {
                      logger.i(
                          "✅ Successfully joined room: ${state.currentRoom!.roomName}");
                      _showSnackBar(
                        "Success",
                        "You successfully joined ${state.currentRoom!.roomName}",
                        ContentType.success,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              RoomScreen(roomEntity: state.currentRoom!),
                        ),
                      );
                    }
                    break;

                  case RoomStatus.error:
                    _closeDialog(context);
                    _showSnackBar(
                      "Error",
                      state.errorMessage ?? "Unable to join the room.",
                      ContentType.failure,
                    );
                    break;

                  default:
                    break;
                }
              },
              child: BlocBuilder<RoomBloc, RoomState>(
                buildWhen: (prev, curr) =>
                prev.status != curr.status ||
                    prev.availableRooms != curr.availableRooms,
                builder: (context, state) {
                  if (state.status == RoomStatus.loadingRooms &&
                      state.availableRooms.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.availableRooms.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: ListView(
                        children: const [
                          SizedBox(height: 200),
                          Center(
                            child: Text(
                              "No rooms available 🚪",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final user = context.read<AuthBloc>().state.user!;

                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      itemCount: state.availableRooms.length,
                      itemBuilder: (context, index) {
                        final RoomEntity room = state.availableRooms[index];

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3E4A59),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.05),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Room name + type
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    room.roomName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurple.shade600,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      "Mixed",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Players + Questions info
                              Row(
                                children: [
                                  const Icon(Icons.people_alt,
                                      size: 18, color: Colors.white70),
                                  const SizedBox(width: 6),
                                  Text(
                                    "${room.user.length}/${room.maxPlayers} Players",
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 13),
                                  ),
                                  const SizedBox(width: 18),
                                  const Icon(Icons.quiz_outlined,
                                      size: 18, color: Colors.white70),
                                  const SizedBox(width: 6),
                                  Text(
                                    "${room.quiz.length} Questions",
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 13),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Status + Join button
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.teal.shade600,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      room.status
                                          .toShortString()
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),

                                  const Spacer(),

                                  GestureDetector(
                                    onTap: () {
                                      if (room.status.isWaiting) {
                                        context.read<RoomBloc>().add(
                                          JoinRoomEvent(
                                            roomId: room.roomId,
                                            userEntity: user,
                                          ),
                                        );
                                      } else {
                                        _showSnackBar(
                                          "Unable to Join",
                                          "This game has already started or finished.",
                                          ContentType.warning,
                                        );
                                      }
                                    },
                                    child: Text(
                                      "Join",
                                      style: TextStyle(
                                        color: Colors.amber.shade400,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
