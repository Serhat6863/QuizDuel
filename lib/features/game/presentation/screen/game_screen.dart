import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quizduel/features/game/presentation/screen/winner_screen.dart';
import 'package:quizduel/features/room/domain/entitiy/room_entity.dart';

class GameScreen extends StatefulWidget {

  final RoomEntity roomEntity;


  const GameScreen({super.key, required this.roomEntity});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int score = 0;
  int questionNumber = 1;
  int totalQuestions = 10;

  int timeLeft = 20; // temps en secondes
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer?.cancel(); // reset si déjà lancé
    timeLeft = 20;
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        t.cancel();
        // ici tu peux déclencher "temps écoulé"
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Temps écoulé ⏳"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6C4),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // HEADER
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "QuizDuel",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Question $questionNumber / $totalQuestions",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Text(
                      "Score: $score",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // QUESTION
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade400,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: const Text(
              "Quelle est la capitale de la France ?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),

          const SizedBox(height: 30),

          // RÉPONSES
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildAnswerButton("Paris", true),
                _buildAnswerButton("Londres", false),
                _buildAnswerButton("Berlin", false),
                _buildAnswerButton("Rome", false),
              ],
            ),
          ),
          
          //button to go to winner Screen
          IconButton(
            onPressed: (){
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WinnerScreen())
              );
            }, icon: Icon(Icons.navigate_next, color: Colors.black87,),
          ),
          
          

          // TIMER EN BAS
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  "Temps restant: $timeLeft s",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                LinearProgressIndicator(
                  value: timeLeft / 20, // 1 → 0
                  backgroundColor: Colors.grey.shade300,
                  color: timeLeft > 5 ? Colors.blue : Colors.red,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerButton(String text, bool isCorrect) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            if (isCorrect) {
              score += 10;
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isCorrect ? "Bonne réponse ✅" : "Mauvaise réponse ❌"),
              backgroundColor: isCorrect ? Colors.green : Colors.red,
            ),
          );
          startTimer(); // reset timer pour la prochaine question
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade400,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
