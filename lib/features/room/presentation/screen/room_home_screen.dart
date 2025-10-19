import 'dart:ui';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizduel/core/theme/app_colors.dart';
import 'package:quizduel/core/theme/app_text_styles.dart';
import 'package:quizduel/core/theme/app_button_styles.dart';
import 'package:quizduel/core/utils/logger.dart';
import 'package:quizduel/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quizduel/features/auth/presentation/bloc/auth_event.dart';
import 'package:quizduel/features/auth/presentation/bloc/auth_state.dart';
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

import '../../../auth/presentation/screen/login_screen.dart';

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

  // 🔹 Dialogue de chargement
  void _showLoadingDialog(BuildContext context, String title) {
    if (_isDialogOpen) return;
    _isDialogOpen = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 20),
              Text(title, style: AppTextStyles.subtitle),
              const SizedBox(height: 8),
              Text(
                "Please wait a few seconds ⏳",
                textAlign: TextAlign.center,
                style: AppTextStyles.hint,
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
        BlocListener<RoomBloc, RoomState>(
          listener: (context, state) {
            switch (state.status) {
              case RoomStatus.creatingRoom:
                _showLoadingDialog(context, "Creating room...");
                break;
              case RoomStatus.roomCreated:
                _closeDialog(context);
                if (state.currentRoom != null && mounted) {
                  logger.i(
                      "✅ Room created successfully: ${state.currentRoom!.roomName}");
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
                  state.errorMessage ?? "Failed to create room.",
                  ContentType.failure,
                );
                break;
              default:
                break;
            }
          },
        ),
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
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.status.isUnauthenticated) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            }else if(state.status.isFailure){
              _showSnackBar(
                "Error",
                state.failure ?? "An error occurred during logout.",
                ContentType.failure,
              );
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 👋 HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // User info
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Hello,", style: AppTextStyles.subtitle),
                        Text(
                          user?.username ?? 'Guest',
                          style: AppTextStyles.pageTitle,
                        ),
                      ],
                    ),

                    // 🔒 Logout
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.15),
                            border: Border.all(
                              color: AppColors.white.withOpacity(0.25),
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadowStrong,
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.logout_rounded,
                              color: AppColors.primary,
                            ),
                            onPressed: () =>
                                context.read<AuthBloc>().add(LoggedOut()),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // 🏆 Stats Card
                Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.25),
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
                              color: AppColors.white, size: 24),
                          SizedBox(width: 8),
                          Text("Your Stats",
                              style: AppTextStyles.cardTitleLight),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text("Keep climbing the ranks!",
                          style: AppTextStyles.subtitleLight),
                      const SizedBox(height: 18),
                      Center(
                        child: Column(
                          children: [
                            Text("${user?.score ?? 0}",
                                style: AppTextStyles.bigNumber),
                            const SizedBox(height: 6),
                            Text("Score",
                                style: AppTextStyles.subtitleLight),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 35),

                const Text("Quick Actions", style: AppTextStyles.sectionTitle),
                const SizedBox(height: 20),

                _buildActionButton(
                  title: "Create Room",
                  color: AppColors.green,
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
                            style: AppButtonStyles.primary,
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
                  color: AppColors.amber,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RoomListScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                _buildActionButton(
                  title: "View Leaderboard",
                  color: AppColors.primary,
                  onPressed: () {
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
        style: AppButtonStyles.colored(color),
        onPressed: onPressed,
        child: Text(title, style: AppTextStyles.button),
      ),
    );
  }
}
