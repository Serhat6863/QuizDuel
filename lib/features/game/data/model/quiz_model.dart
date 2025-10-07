import 'package:quizduel/features/game/domain/entity/quiz_entity.dart';

class QuizModel extends QuizEntity {
  QuizModel({
    required super.category,
    required super.difficulty,
    required super.question,
    required super.options,
    required super.correctAnswerIndex,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    // ⚙️ Si la réponse vient de l’API OpenTrivia
    if (json.containsKey('correct_answer')) {
      final correctAnswer = json['correct_answer'] as String;
      final incorrectAnswers = List<String>.from(json['incorrect_answers'] ?? []);

      // Construit et mélange les options
      final allOptions = [...incorrectAnswers, correctAnswer]..shuffle();

      return QuizModel(
        category: json['category'] ?? '',
        difficulty: json['difficulty'] ?? '',
        question: json['question'] ?? '',
        options: allOptions,
        correctAnswerIndex: allOptions.indexOf(correctAnswer),
      );
    }

    // ⚙️ Si les données viennent de Firebase
    return QuizModel(
      category: json['category'] ?? '',
      difficulty: json['difficulty'] ?? '',
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswerIndex: json['correctAnswerIndex'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'category': category,
    'difficulty': difficulty,
    'question': question,
    'options': options,
    'correctAnswerIndex': correctAnswerIndex,
  };

  QuizEntity toEntity() => QuizEntity(
    category: category,
    difficulty: difficulty,
    question: question,
    options: options,
    correctAnswerIndex: correctAnswerIndex,
  );
}
