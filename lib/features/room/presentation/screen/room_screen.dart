import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

class RoomScreen extends StatelessWidget {
  final String roomName;

  // Dummy joueurs
  final List<Map<String, dynamic>> players = [
    {"name": "Player1", "isHost": true},
    {"name": "Player2", "isHost": false},
    {"name": "Player3", "isHost": false},
  ];

  RoomScreen({super.key, required this.roomName});

  @override
  Widget build(BuildContext context) {
    final host = players.firstWhere((p) => p["isHost"] == true);

    return Scaffold(
      backgroundColor: const Color(0xFFF5E6C4),
      body: Column(
        children: [
          // HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, bottom: 20),
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Center(
              child: Text(
                "Room: $roomName",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            "Players 3/4",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          // Liste des joueurs
          Expanded(
            child: ListView.builder(
              itemCount: players.length,
              itemBuilder: (context, index) {
                final player = players[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: player["isHost"]
                          ? Colors.amber.shade700
                          : Colors.grey.shade400,
                      child: Icon(
                        player["isHost"] ? Icons.star : Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(player["name"]),
                    subtitle: player["isHost"]
                        ? const Text(
                      "Host 👑",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                        : null,
                  ),
                );
              },
            ),
          ),

          // Boutons du host
          if (host["name"] == "Player1") ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.play_arrow, color: Colors.white),
                label: const Text(
                  "Start the Game",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Game Started! 🚀")),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.delete, color: Colors.white),
                label: const Text(
                  "Delete Room",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                onPressed: () {
                  Navigator.pop(context); // simule suppression

                  final snackBar = SnackBar(
                    elevation: 0,
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.transparent, // 👈 important pour AwesomeSnackbar
                    content: AwesomeSnackbarContent(
                      title: 'Room Deleted',
                      message: 'The room has been successfully deleted.',
                      contentType: ContentType.success,
                    ),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },

              ),
            ),
          ],
        ],
      ),
    );
  }
}
