import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:quizduel/core/theme/app_colors.dart';
import 'package:quizduel/core/theme/app_text_styles.dart';
import 'package:quizduel/core/theme/app_button_styles.dart';
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
  final player = AudioPlayer();
  int score = 0;
  int questionNumber = 0;
  int totalQuestions = 10;
  bool? isAnswerCorrect;
  int? selectedAnswerIndex;
  late final currentUser;
  final unescape = HtmlUnescape();

  int timeLeft = 10;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startTimer();
    currentUser = context.read<AuthBloc>().state.user!;
  }

  void nextQuestion() {
    if (questionNumber < totalQuestions - 1) {
      setState(() {
        questionNumber++;
        selectedAnswerIndex = null;
        isAnswerCorrect = null;
      });
      startTimer();
    } else {
      context.read<RoomBloc>().add(
        UpdateFinalScoreEvent(
          roomId: widget.roomEntity.roomId,
          userId: currentUser.id,
          newScore: score,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WinnerScreen(roomEntity: widget.roomEntity),
        ),
      );
    }
  }

  void startTimer() {
    timer?.cancel();
    timeLeft = 10;
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeLeft > 0) {
        setState(() => timeLeft--);
      } else {
        t.cancel();
        nextQuestion();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.roomEntity.quiz[questionNumber];
    final decodedQuestion = unescape.convert(question.question);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 🟣 HEADER
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("QuizDuel", style: AppTextStyles.headerWhite),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Question ${questionNumber + 1} / $totalQuestions",
                      style: AppTextStyles.smallLabel,
                    ),
                    Text(
                      "Score: $score",
                      style: AppTextStyles.gameInfo,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 🧠 QUESTION CARD
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowSoft,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              decodedQuestion,
              textAlign: TextAlign.center,
              style: AppTextStyles.question,
            ),
          ),

          const SizedBox(height: 30),

          // 🔘 ANSWERS
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: ListView.builder(
                itemCount: question.options.length,
                itemBuilder: (context, index) {
                  final decodedOption =
                  unescape.convert(question.options[index]);
                  final isCorrect =
                      index == question.correctAnswerIndex;
                  return _buildAnswerButton(decodedOption, isCorrect, index);
                },
              ),
            ),
          ),

          // ⏳ TIMER
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text("Time left: $timeLeft s", style: AppTextStyles.timer),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: timeLeft / 10,
                    backgroundColor: AppColors.white70,
                    color: timeLeft > 5 ? AppColors.primary : AppColors.red,
                    minHeight: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerButton(String text, bool isCorrect, int index) {
    final correctIndex = widget.roomEntity.quiz[questionNumber].correctAnswerIndex;

    Color buttonColor() {
      if (selectedAnswerIndex == null) return AppColors.primary;
      if (index == selectedAnswerIndex && selectedAnswerIndex == correctIndex) {
        return AppColors.green;
      }
      if (index == selectedAnswerIndex && selectedAnswerIndex != correctIndex) {
        return AppColors.red;
      }
      if (index == correctIndex) return AppColors.green;
      return AppColors.primary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: ElevatedButton(
        onPressed: () {
          if (selectedAnswerIndex != null) return;

          setState(() {
            selectedAnswerIndex = index;
            isAnswerCorrect = isCorrect;

            if (isCorrect) {
              score += 10;
              player.stop();
              player.play(AssetSource("sound/winner.mp3"));
            } else {
              player.stop();
              player.play(AssetSource("sound/negative.mp3"));
            }
          });
        },
        style: AppButtonStyles.primary.copyWith(
          backgroundColor: WidgetStateProperty.all(buttonColor()),
        ),
        child: Text(text, style: AppTextStyles.answer),
      ),
    );
  }
}
