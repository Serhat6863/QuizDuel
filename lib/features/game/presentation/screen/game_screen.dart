import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:quizduel/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quizduel/features/game/presentation/screen/winner_screen.dart';
import 'package:quizduel/features/room/domain/entitiy/room_entity.dart';
import 'package:quizduel/features/room/presentation/bloc/room_bloc.dart';
import 'package:quizduel/features/room/presentation/bloc/room_event.dart';

class GameScreen extends StatefulWidget {

  final RoomEntity roomEntity;

  const GameScreen({super.key, required this.roomEntity});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {



  int score = 0;
  int questionNumber = 0;
  int totalQuestions = 10;
  bool? isAnswerCorrect;
  int? selectedAnswerIndex;
  late final currentUser;
  final unescape = HtmlUnescape();

  int timeLeft = 10; // temps en secondes
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startTimer();
    currentUser = context.read<AuthBloc>().state.user!;
  }


  void nextQuestion(){
    if(questionNumber < totalQuestions -1){
      setState(() {
        questionNumber++;
        selectedAnswerIndex = null;
        isAnswerCorrect = null;
      });
      startTimer();
    }else{
      //update last score to roomEntity player
      context.read<RoomBloc>().add(UpdateFinalScoreEvent(
        roomId: widget.roomEntity.roomId,
        userId: currentUser.id,
        newScore: score,
      ));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WinnerScreen(roomEntity: widget.roomEntity,),
        )
      );
    }
  }


  void startTimer() {
    timer?.cancel(); // reset si déjà lancé
    timeLeft = 10;
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        t.cancel();
        nextQuestion();
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
                      "Question ${questionNumber + 1} / $totalQuestions",
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
            child:  Text(
              unescape.convert(widget.roomEntity.quiz[questionNumber].question),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),

          const SizedBox(height: 30),

          // RÉPONSES
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: widget.roomEntity.quiz[questionNumber].options.length,
                itemBuilder: (context, index){
                  final answer = widget.roomEntity.quiz[questionNumber];
                  final decodedOption = unescape.convert(answer.options[index]);
                  final isCorrect = index == widget.roomEntity.quiz[questionNumber].correctAnswerIndex;
                  return _buildAnswerButton(decodedOption, isCorrect);
                }
              ),
            )
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
                  value: timeLeft / 10, // 1 → 0
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
            selectedAnswerIndex = widget.roomEntity.quiz[questionNumber].options.indexOf(text);
            isAnswerCorrect = isCorrect;
            if (isCorrect) {
              score += 10;
            }
          });
          // reset timer pour la prochaine question
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: selectedAnswerIndex == widget.roomEntity.quiz[questionNumber].options.indexOf(text)
              ? (isAnswerCorrect! ? Colors.green : Colors.red)
              : Colors.blue,
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
