import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizduel/features/room/presentation/widget/custom_card_widget.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/screen/login_screen.dart';

class RoomHomeScreen extends StatefulWidget {
  const RoomHomeScreen({super.key});

  @override
  State<RoomHomeScreen> createState() => _RoomHomeScreenState();
}

class _RoomHomeScreenState extends State<RoomHomeScreen> {
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
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF6A11CB), // violet
                Color(0xFF2575FC), // bleu clair
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: CustomCardWidget(
                  title: "Create Room",
                  subtitle: "Launch a game",
                  iconData: Icons.add_circle_outline,
                  onTap: () {},
                  buttonText: "Create",
                  buttonColor: Colors.deepPurple,
                ),
              ),

              const SizedBox(height: 15,),

              Padding(
                padding: const EdgeInsets.all(12),
                child: CustomCardWidget(
                  title: "Join Room",
                  subtitle: "Enter a existing room",
                  iconData: Icons.group_add,
                  onTap: () {},
                  buttonText: "Join",
                  buttonColor: Colors.green,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
