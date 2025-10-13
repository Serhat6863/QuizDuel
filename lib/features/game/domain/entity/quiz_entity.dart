class QuizEntity{
  final String category;
  final String difficulty;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;

  QuizEntity({
    required this.category,
    required this.difficulty,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
  });
}