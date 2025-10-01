import 'package:flutter/material.dart';

class RoomListScreen extends StatefulWidget {
  const RoomListScreen({super.key});

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  // ✅ Dummy rooms
  final List<Map<String, dynamic>> rooms = [
    {"name": "Room Alpha", "players": 2},
    {"name": "Room Beta", "players": 4},
    {"name": "Room Gamma", "players": 1},
    {"name": "Room Delta", "players": 3},
    {"name": "Room Omega", "players": 2},
  ];

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
                    const SizedBox(width: 48), // équilibre l’icône retour
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),


          // ✅ Liste des rooms
          Expanded(
            child: ListView.builder(
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.videogame_asset, color: Colors.deepPurple),
                    title: Text(
                      room["name"],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("${room["players"]}/4 players"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () {
                      // Navigue vers la room sélectionnée
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Joining ${room["name"]}...")),
                      );
                    },
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
