import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizduel/core/utils/logger.dart';
import 'package:quizduel/features/room/domain/entitiy/room_entity.dart';
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
    logger.i("📡 Chargement initial des rooms...");
    context.read<RoomBloc>().add(FetchAvailableRoomsEvent());
  }

  Future<void> _onRefresh() async {
    logger.i("🔄 Rafraîchissement manuel de la liste des rooms");
    context.read<RoomBloc>().add(FetchAvailableRoomsEvent());
  }

  void _showLoadingDialog(BuildContext context, String message) {
    if (_isDialogOpen) return;
    _isDialogOpen = true;
    logger.d("⏳ Affichage du dialog: $message");

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
      logger.d("❌ Fermeture du dialog de chargement");
      Navigator.of(context, rootNavigator: true).pop();
      _isDialogOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6C4),
      body: Column(
        children: [
          // HEADER
          Container(
            decoration: BoxDecoration(
              color: Colors.amber.shade600,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        logger.i("↩️ Retour à la page précédente");
                        Navigator.pop(context);
                      },
                    ),
                    const Text(
                      "Available Rooms",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // LISTE DES ROOMS
          Expanded(
            child: BlocListener<RoomBloc, RoomState>(
              listenWhen: (prev, curr) => prev.status != curr.status,
              listener: (context, state) {
                switch (state.status) {
                  case RoomStatus.joiningRoom:
                    logger.i("🔗 Connexion à une room en cours...");
                    _showLoadingDialog(context, "Connexion à la room...");
                    break;

                  case RoomStatus.roomCreated:
                    if (state.currentRoom != null) {
                      logger.i("✅ Connexion réussie à la room: ${state.currentRoom!.roomName}");
                      _closeDialog(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RoomScreen(roomEntity: state.currentRoom!),
                        ),
                      );
                    }
                    break;

                  case RoomStatus.error:
                    logger.e("❌ Erreur lors de la connexion: ${state.errorMessage}");
                    _closeDialog(context);
                    final snackBar = SnackBar(
                      elevation: 0,
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.transparent,
                      content: AwesomeSnackbarContent(
                        title: 'Erreur',
                        message: state.errorMessage ?? "Impossible de rejoindre la room",
                        contentType: ContentType.failure,
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    break;

                  default:
                    break;
                }
              },
              child: BlocBuilder<RoomBloc, RoomState>(
                buildWhen: (previous, current) =>
                previous.status != current.status ||
                    previous.availableRooms != current.availableRooms,
                builder: (context, state) {
                  if (state.status == RoomStatus.loadingRooms &&
                      state.availableRooms.isEmpty) {
                    logger.d("📭 Chargement des rooms en cours...");
                    return const Center(child: CircularProgressIndicator());
                  } else if (state.availableRooms.isEmpty) {
                    logger.w("⚠️ Aucune room disponible actuellement");
                    return RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: ListView(
                        children: const [
                          SizedBox(height: 200),
                          Center(child: Text("Aucune room disponible 🚪")),
                        ],
                      ),
                    );
                  } else {
                    final user = context.read<AuthBloc>().state.user;
                    if (user == null) {
                      logger.w("⚠️ Aucun utilisateur connecté");
                      return const Center(
                          child: Text("Veuillez vous connecter 🔐"));
                    }

                    logger.i("🎮 ${state.availableRooms.length} rooms disponibles");
                    return RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: state.availableRooms.length,
                        itemBuilder: (context, index) {
                          final RoomEntity room = state.availableRooms[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.videogame_asset,
                                  color: Colors.deepPurple),
                              title: Text(
                                room.roomName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                "${room.user.length} / ${room.maxPlayers} joueurs",
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios,
                                  size: 18),
                              onTap: () {
                                logger.i("👥 Tentative de rejoindre la room: ${room.roomName}");
                                context.read<RoomBloc>().add(
                                  JoinRoomEvent(
                                    roomId: room.roomId,
                                    userEntity: user,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
