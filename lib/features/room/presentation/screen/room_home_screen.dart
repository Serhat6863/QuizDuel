import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizduel/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quizduel/features/auth/presentation/bloc/auth_event.dart';
import 'package:quizduel/features/auth/presentation/bloc/auth_state.dart';
import 'package:quizduel/features/auth/presentation/screen/login_screen.dart';
import 'package:quizduel/features/room/domain/entitiy/room_entity.dart';
import 'package:quizduel/features/room/presentation/bloc/room_bloc.dart';
import 'package:quizduel/features/room/presentation/bloc/room_event.dart';
import 'package:quizduel/features/room/presentation/bloc/room_state.dart';
import 'package:quizduel/features/room/presentation/screen/room_list_screen.dart';
import 'package:quizduel/features/room/presentation/screen/room_screen.dart';

class RoomHomeScreen extends StatefulWidget {
  const RoomHomeScreen({super.key});

  @override
  State<RoomHomeScreen> createState() => _RoomHomeScreenState();
}

class _RoomHomeScreenState extends State<RoomHomeScreen>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  final int _cardCount = 4; // Nombre total de cartes
  final TextEditingController _roomNameController = TextEditingController();
  final TextEditingController _joinCodeController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      _cardCount,
          (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );

    _fadeAnimations = _controllers
        .map((controller) => CurvedAnimation(
      parent: controller,
      curve: Curves.easeIn,
    ))
        .toList();

    _slideAnimations = _controllers
        .map((controller) => Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOut,
    )))
        .toList();

    // Lancer les animations en décalé
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) _controllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    _roomNameController.dispose();
    _joinCodeController.dispose();
    super.dispose();
  }

  // 🔥 Carte avec animation staggered
  Widget buildGlassCard({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return FadeTransition(
      opacity: _fadeAnimations[index],
      child: SlideTransition(
        position: _slideAnimations[index],
        child: GestureDetector(
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: color.withOpacity(0.8),
                      radius: 28,
                      child: Icon(icon, color: Colors.white, size: 28),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
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
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: IconButton(
            onPressed: (){
              context.read<AuthBloc>().add(LoggedOut());
            },
            icon: const Icon(Icons.logout, color: Colors.white,),
          ),
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7F00FF), Color(0xFFE100FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
          ),
          title: Column(
            children: const [
              Text(
                "QuizDuel",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              SizedBox(height: 2),
              Text(
                "Challenge your friends!",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          centerTitle: true,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF8F9FA), Color(0xFFEDE7F6)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: BlocConsumer<RoomBloc, RoomState>(
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
              return SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      "Welcome to QuizDuel 🎮",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Create or join a room and start playing!",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 30),

                    // 🟪 Grid avec 4 cartes
                    Expanded(
                      child: GridView.count(
                        padding: const EdgeInsets.all(16),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: [
                          buildGlassCard(
                            index: 0,
                            icon: Icons.edit,
                            title: "Create Room",
                            subtitle: "Start a new game",
                            color: Colors.deepPurple,
                            onTap: () {
                              showDialog(
                                context: context,
                                barrierDismissible: false, // empêche de fermer en cliquant à côté
                                builder: (context) {
                                  return BlocBuilder<RoomBloc, RoomState>(
                                    builder: (context, state) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        title: const Text("Create Room"),
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
                                                  } else if (value.length > 6) {
                                                    return "Max 6 characters";
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
                                                  } else if (value.length > 4) {
                                                    return "Max 4 characters";
                                                  }
                                                  return null;
                                                },
                                              ),
                                              const SizedBox(height: 20),

                                              // 🔥 Bouton Create avec vrai loading
                                              SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.deepPurple,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                                  ),
                                                  onPressed: state.status.isLoading
                                                      ? null
                                                      : () {
                                                    final authState =
                                                        context.read<AuthBloc>().state;
                                                    if (formKey.currentState!.validate() &&
                                                        authState.user != null) {
                                                      context.read<RoomBloc>().add(
                                                        CreateRoomEvent(
                                                          roomEntity: RoomEntity(
                                                            roomId: '',
                                                            roomName: _roomNameController.text,
                                                            hostId: authState.user!.id,
                                                            user: [authState.user!],
                                                            maxPlayers: 4,
                                                            createdAt: DateTime.now(),
                                                            status: "waiting",
                                                            joinCode: _joinCodeController.text,
                                                            quizId: "",
                                                            isHost: true,
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  child: state.status.isLoading
                                                      ? Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: const [
                                                      SizedBox(
                                                        width: 22,
                                                        height: 22,
                                                        child: CircularProgressIndicator(
                                                          color: Colors.white,
                                                          strokeWidth: 2,
                                                        ),
                                                      ),
                                                      SizedBox(width: 12),
                                                      Text(
                                                        "Creating...",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                      : const Text(
                                                    "Create",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
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
                              );

                            },
                          ),
                          buildGlassCard(
                            index: 1,
                            icon: Icons.group,
                            title: "See Rooms",
                            subtitle: "Join existing",
                            color: Colors.pink,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const RoomListScreen(),
                                ),
                              );
                            },
                          ),
                          buildGlassCard(
                            index: 2,
                            icon: Icons.people,
                            title: "Friends",
                            subtitle: "Find & invite",
                            color: Colors.green,
                            onTap: () {
                              // logique future pour les amis
                            },
                          ),
                          buildGlassCard(
                            index: 3,
                            icon: Icons.settings,
                            title: "Settings",
                            subtitle: "Customize",
                            color: Colors.blueGrey,
                            onTap: () {
                              // logique future pour settings
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
