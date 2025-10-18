import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizduel/core/theme/app_colors.dart';
import 'package:quizduel/core/theme/app_text_styles.dart';
import 'package:quizduel/core/theme/app_button_styles.dart';
import 'package:quizduel/features/room/presentation/bloc/leader_bloc.dart';
import 'package:quizduel/features/room/presentation/bloc/leader_event.dart';
import 'package:quizduel/features/room/presentation/bloc/leader_state.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LeaderBloc>().add(FetchLeaderBoardEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // 🌟 HEADER
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.blueGradient,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowStrong,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.only(top: 50, bottom: 25),
            child: Row(
              children: [
                const SizedBox(width: 20),
                // 🔙 Bouton retour
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.white70),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      CupertinoIcons.back,
                      color: AppColors.white,
                      size: 22,
                    ),
                  ),
                ),
                const Spacer(),
                const Text(
                  "Leaderboard",
                  style: AppTextStyles.headerWhite,
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 🏆 CONTENU
          Expanded(
            child: BlocBuilder<LeaderBloc, LeaderState>(
              builder: (context, state) {
                if (state.status.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                } else if (state.status.isFailure) {
                  return Center(
                    child: Text(
                      "Error loading leaderboard",
                      style: AppTextStyles.failure,
                    ),
                  );
                } else if (state.status.isSuccess) {
                  if (state.leaders.isEmpty) {
                    return const Center(
                      child: Text(
                        "Leaderboard is empty",
                        style: AppTextStyles.subtitle,
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: state.leaders.length,
                    itemBuilder: (context, index) {
                      final leader = state.leaders[index];

                      // 🥇 Couleurs podium
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
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: rankColor,
                            radius: 22,
                            child: Text(
                              "${index + 1}",
                              style: AppTextStyles.rankNumber,
                            ),
                          ),
                          title: Text(
                            leader.username,
                            style: AppTextStyles.listTitle,
                          ),
                          trailing: Text(
                            "${leader.score ?? 0} pts",
                            style: AppTextStyles.listSubtitle,
                          ),
                        ),
                      );
                    },
                  );
                }

                return const Center(
                  child: Text(
                    "No data available",
                    style: AppTextStyles.subtitle,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
