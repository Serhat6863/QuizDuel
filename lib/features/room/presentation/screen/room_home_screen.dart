import 'dart:ui';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizduel/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quizduel/features/auth/presentation/bloc/auth_event.dart';
import 'package:quizduel/features/game/presentation/bloc/quiz_bloc.dart';
import 'package:quizduel/features/game/presentation/bloc/quiz_event.dart';
import 'package:quizduel/features/game/presentation/bloc/quiz_state.dart';
import 'package:quizduel/features/room/data/model/room_model.dart';
import 'package:quizduel/features/room/domain/enums/room_game_status.dart';
import 'package:quizduel/features/room/presentation/bloc/room_bloc.dart';
import 'package:quizduel/features/room/presentation/bloc/room_event.dart';
import 'package:quizduel/features/room/presentation/screen/leaderboard_screen.dart';
import 'package:quizduel/features/room/presentation/screen/room_list_screen.dart';
import 'package:quizduel/features/room/presentation/screen/room_screen.dart';
import 'package:quizduel/features/room/presentation/widget/build_menu_card.dart';
import 'package:quizduel/core/utils/logger.dart';
import '../bloc/room_state.dart';
import '../widget/build_stat_box.dart';

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
      builder: (context) => Dialog(
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
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Merci de patienter quelques secondes ⏳",
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

  void _createRoom(BuildContext context, String roomName) {
    final user = context.read<AuthBloc>().state.user!;
    final quizState = context.read<QuizBloc>().state;

    logger.i("Tentative de création de room $roomName par ${user.username}");

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
      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Erreur',
          message: "Impossible de créer la room, aucun quiz n’a été chargé 😢",
          contentType: ContentType.failure,
        ),
      );
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthBloc>().state.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF5E6C4),
      body: Column(
        children: [
          // HEADER
          Container(
            padding:
            const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple.shade500,
                  Colors.deepPurple.shade400,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // top bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "QuizDuel",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Row(
                      children: [
                        // 🔹 Logout button — effet vitre moderne
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
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
                                icon: const Icon(
                                  Icons.logout_rounded,
                                  color: Colors.white,
                                ),
                                tooltip: "Se déconnecter",
                                onPressed: () => context
                                    .read<AuthBloc>()
                                    .add(LoggedOut()),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          user?.username ?? 'Invité',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    BuildStatBox(
                      label: "Rooms",
                      value: context
                          .read<RoomBloc>()
                          .state
                          .availableRooms
                          .length,
                    ),
                    BuildStatBox(label: "Score", value: user?.score ?? 0),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // BODY
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                BuildMenuCard(
                  icon: Icons.list,
                  title: "Voir les Rooms",
                  color: Colors.amber.shade600,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RoomListScreen(),
                      ),
                    );
                  },
                ),
                BuildMenuCard(
                  icon: Icons.add,
                  title: "Créer une Room",
                  color: Colors.green.shade600,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Nom de la Room"),
                        content: TextField(
                          controller: _roomNameController,
                          decoration: const InputDecoration(
                            hintText: "Entrez un nom",
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Annuler"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              final roomName =
                              _roomNameController.text.trim();
                              if (roomName.isNotEmpty) {
                                context.read<QuizBloc>().add(FetchQuizEvent());
                                Navigator.pop(context);
                              }
                            },
                            child: const Text("Créer"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                BuildMenuCard(
                  icon: Icons.star,
                  title: "Classement",
                  color: Colors.blue.shade600,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LeaderboardScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
