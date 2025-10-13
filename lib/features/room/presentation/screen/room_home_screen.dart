import 'dart:ui';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizduel/core/utils/logger.dart';
import 'package:quizduel/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quizduel/features/auth/presentation/bloc/auth_event.dart';
import 'package:quizduel/features/game/presentation/bloc/quiz_bloc.dart';
import 'package:quizduel/features/game/presentation/bloc/quiz_event.dart';
import 'package:quizduel/features/game/presentation/bloc/quiz_state.dart';
import 'package:quizduel/features/room/data/model/room_model.dart';
import 'package:quizduel/features/room/domain/enums/room_game_status.dart';
import 'package:quizduel/features/room/presentation/bloc/room_bloc.dart';
import 'package:quizduel/features/room/presentation/bloc/room_event.dart';
import 'package:quizduel/features/room/presentation/bloc/room_state.dart';
import 'package:quizduel/features/room/presentation/screen/leaderboard_screen.dart';
import 'package:quizduel/features/room/presentation/screen/room_list_screen.dart';
import 'package:quizduel/features/room/presentation/screen/room_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _roomNameController = TextEditingController();
  bool _isDialogOpen = false;

  @override
  void initState() {
    super.initState();
    context.read<RoomBloc>().add(FetchAvailableRoomsEvent());
    Future.delayed(const Duration(milliseconds: 300), () {
      context.read<AuthBloc>().add(RefreshUserEvent());
    });
  }





  @override
  void dispose() {
    _roomNameController.dispose();
    super.dispose();
  }

  void _showLoadingDialog(BuildContext context, String title) {
    if (_isDialogOpen) return;
    _isDialogOpen = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.deepPurple),
              const SizedBox(height: 20),
              Text(
                title,
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

  void _createRoom(BuildContext context, String roomName) {
    final user = context.read<AuthBloc>().state.user!;
    final quizState = context.read<QuizBloc>().state;

    logger.i("Attempting to create room $roomName by ${user.username}");

    if (quizState.status.isLoaded && quizState.quizzes.isNotEmpty) {
      context.read<RoomBloc>().add(
        CreateRoomEvent(
          roomEntity: RoomModel(
            roomId: "",
            roomName: roomName,
            hostId: user.id,
            user: [user],
            status: RoomGameStatus.waiting,
            joinCode: "",
            createdAt: DateTime.now(),
            maxPlayers: 4,
            quiz: quizState.quizzes,
          ),
        ),
      );
      _closeDialog(context);
    } else {
      _showSnackBar(
        "Error",
        "Unable to create room — no quizzes loaded 😢",
        ContentType.failure,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthBloc>().state.user;

    return MultiBlocListener(
      listeners: [
        /// 🧩 ROOM BLOC
        BlocListener<RoomBloc, RoomState>(
          listenWhen: (prev, curr) => prev.status != curr.status,
          listener: (context, state) {
            switch (state.status) {
              case RoomStatus.creatingRoom:
                _showLoadingDialog(context, "Creating room...");
                break;

              case RoomStatus.roomCreated:
                _closeDialog(context);
                if (state.currentRoom != null && mounted) {
                  logger.i("✅ Room created successfully: ${state.currentRoom!.roomName}");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RoomScreen(roomEntity: state.currentRoom!),
                    ),
                  );
                }
                break;

              case RoomStatus.error:
                _closeDialog(context);
                _showSnackBar(
                  "Error",
                  state.errorMessage ?? "Failed to create room.",
                  ContentType.failure,
                );
                break;

              default:
                break;
            }
          },
        ),

        /// 🧠 QUIZ BLOC
        BlocListener<QuizBloc, QuizState>(
          listener: (context, quizState) {
            switch (quizState.status) {
              case QuizStatus.loading:
                _showLoadingDialog(context, "Loading quizzes...");
                break;

              case QuizStatus.loaded:
                _closeDialog(context);
                final roomName = _roomNameController.text.trim();
                if (roomName.isNotEmpty) {
                  _createRoom(context, roomName);
                }
                break;

              case QuizStatus.error:
                _closeDialog(context);
                _showSnackBar(
                  "Error",
                  quizState.message ?? "Failed to load quizzes 😢",
                  ContentType.failure,
                );
                break;

              default:
                break;
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF5E6C4),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 👋 HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hello,",
                            style: TextStyle(
                              color: Colors.deepPurple.shade400,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            user?.username ?? 'Guest',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      // 🔒 LOGOUT (Glass effect)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.25),
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.logout_rounded,
                                  color: Colors.deepPurple),
                              onPressed: () =>
                                  context.read<AuthBloc>().add(LoggedOut()),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // 🏆 STATS CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepPurple.shade400,
                          Colors.deepPurple.shade300,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.emoji_events,
                                color: Colors.white, size: 24),
                            SizedBox(width: 8),
                            Text(
                              "Your Stats",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Keep climbing the ranks!",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 18),
                        Center(
                          child: Column(
                            children: [
                              Text(
                                "${user?.score ?? 0}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "Score",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),

                  const Text(
                    "Quick Actions",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildActionButton(
                    title: "Create Room",
                    color: Colors.green.shade600,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Room Name"),
                          content: TextField(
                            controller: _roomNameController,
                            decoration: const InputDecoration(
                              hintText: "Enter a name",
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                final roomName = _roomNameController.text.trim();
                                if (roomName.isNotEmpty) {
                                  context.read<QuizBloc>().add(FetchQuizEvent());
                                  Navigator.pop(context);
                                }
                              },
                              child: const Text("Create"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  _buildActionButton(
                    title: "Browse Rooms",
                    color: Colors.amber.shade600,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RoomListScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  _buildActionButton(
                    title: "View Leaderboard",
                    color: Colors.blue.shade600,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 3,
        ),
        onPressed: onPressed,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
