import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizduel/core/theme/app_colors.dart';
import 'package:quizduel/core/theme/app_text_styles.dart';
import 'package:quizduel/core/theme/app_button_styles.dart';
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
  late List sortedUsers;

  @override
  void initState() {
    super.initState();
    sortUsersByScore();

    // 🔄 Re-fetch des données du salon
    context.read<RoomBloc>().add(
      GetRoomByIdEvent(roomId: widget.roomEntity.roomId),
    );
  }

  void sortUsersByScore() {
    final users = [...widget.roomEntity.user];
    users.sort((a, b) => (b.score ?? 0).compareTo(a.score ?? 0));
    setState(() => sortedUsers = users);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🌈 HEADER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 35),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowStrong,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text("QuizDuel", style: AppTextStyles.headerWhite),
              ),
            ),

            const Spacer(),

            // 🏆 WINNER SECTION
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.emoji_events,
                  size: 100,
                  color: AppColors.amber,
                ),
                const SizedBox(height: 10),
                Text("Winner!", style: AppTextStyles.winnerTitle),
                const SizedBox(height: 30),

                // 🧑‍💻 Liste des joueurs
                BlocBuilder<RoomBloc, RoomState>(
                  builder: (context, state) {
                    final room = state.currentRoom ?? widget.roomEntity;
                    final users = [...room.user];
                    users.sort((a, b) => (b.score ?? 0).compareTo(a.score ?? 0));

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: users.length,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemBuilder: (context, index) {
                        final user = users[index];

                        // 🥇 Couleur du rang
                        Color rankColor;
                        if (index == 0) {
                          rankColor = AppColors.amber;
                        } else if (index == 1) {
                          rankColor = AppColors.greyLight;
                        } else if (index == 2) {
                          rankColor = AppColors.brownLight;
                        } else {
                          rankColor = AppColors.blueGrey;
                        }

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadowSoft,
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: rankColor,
                              radius: 24,
                              child: Text(
                                "${index + 1}",
                                style: AppTextStyles.rankNumber,
                              ),
                            ),
                            title: Text(user.username,
                                style: AppTextStyles.listTitle),
                            trailing: Text(
                              "Score: ${user.score ?? 0}",
                              style: AppTextStyles.listSubtitle,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 60),

                // 🏠 Retour à l'accueil
                BlocListener<RoomBloc, RoomState>(
                  listener: (context, state) {
                    if (state.status == RoomStatus.roomDeleted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                            (route) => false,
                      );
                    }
                  },
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<RoomBloc>().add(
                        DeleteRoomEvent(roomId: widget.roomEntity.roomId),
                      );
                    },
                    style: AppButtonStyles.primary,
                    icon: const Icon(Icons.home, color: AppColors.white),
                    label: const Text("Return Home",
                        style: AppTextStyles.button),
                  ),
                ),
              ],
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}
