import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      backgroundColor: const Color(0xFFF5E6C4),
      body: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade600,
                  Colors.blue.shade400,
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
                  color: Colors.blue.shade200.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.only(top: 50, bottom: 25),
            child: Row(
              children: [
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      CupertinoIcons.back,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                const Spacer(),
                const Text(
                  "Leaderboard",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Leaderboard list
          Expanded(
            child: BlocBuilder<LeaderBloc, LeaderState>(
              builder: (context, state) {
                if (state.status.isLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue.shade400,
                    ),
                  );
                } else if (state.status.isFailure) {
                  return Center(
                    child: Text(
                      "Erreur de chargement",
                      style: TextStyle(
                        color: Colors.red.shade400,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                } else if (state.status.isSuccess) {
                  if (state.leaders.isEmpty) {
                    return Center(
                      child: Text(
                        "Leaderboard vide",
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: state.leaders.length,
                    itemBuilder: (context, index) {
                      final leader = state.leaders[index];

                      // Couleurs pour top 3
                      Color rankColor;
                      if (index == 0) {
                        rankColor = Colors.amber.shade600;
                      } else if (index == 1) {
                        rankColor = Colors.grey.shade400;
                      } else if (index == 2) {
                        rankColor = Colors.brown.shade400;
                      } else {
                        rankColor = Colors.blueGrey.shade200;
                      }

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
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
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            leader.username,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          trailing: Text(
                            "${leader.score ?? 0} pts",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }

                return Center(
                  child: Text(
                    "Aucune donnée",
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
