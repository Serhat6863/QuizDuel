import 'package:flutter/material.dart';
import 'package:quizduel/features/room/presentation/screen/room_home_screen.dart';

class WinnerScreen extends StatefulWidget {
  const WinnerScreen({super.key});

  @override
  State<WinnerScreen> createState() => _WinnerScreenState();
}

class _WinnerScreenState extends State<WinnerScreen> {


  List<Map<String, dynamic>> rooms = [
    {"name": "Serhat", "players": 2, "score": 150},
    {"name": "Samet", "players": 4, "score": 200},
    {"name": "Fikret", "players": 1 , "score": 100},
    {"name": "Ahmet", "players": 3, "score": 250},
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6C4),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            decoration: BoxDecoration(
              color: Colors.blue.shade400,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: const Center(
              child: Text(
                "QuizDuel",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const Spacer(),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events,
                size: 100,
                color: Colors.amber.shade700,
              ),
              const SizedBox(height: 10),
              Text(
                "Winner!",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),


              const SizedBox(height: 20),

              //faire une liste pour afficher les scores des joueurs en fontion du score celui qui a le plus de points en haut
              Column(
                children: rooms.map((room) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 40),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            room["name"],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Score: ${room["score"]}",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),


              const SizedBox(height: 100,),


              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade400,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Home",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.home, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),

          const Spacer(),
        ],
      ),
    );
  }
}
