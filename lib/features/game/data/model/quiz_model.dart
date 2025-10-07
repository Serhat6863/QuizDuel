import 'package:quizduel/features/game/domain/entity/quiz_entity.dart';

class QuizModel extends QuizEntity{
  QuizModel({
    required super.question,
    required super.category,
    required super.difficulty,
    required super.correctAnswerIndex,
    required super.options,
  });


  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      category: json['category'] ?? '',
      difficulty: json['difficulty'] ?? '',
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswerIndex: json['correctAnswerIndex'] ?? 0,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'category': category ?? '',
      'difficulty': difficulty ?? '',
      'question': question ?? '',
      'options': options ?? [],
      'correctAnswerIndex': correctAnswerIndex ?? 0,
    };
  }

  QuizEntity toEntity() {
    return QuizEntity(
      category: category,
      difficulty: difficulty,
      question: question,
      options: options,
      correctAnswerIndex: correctAnswerIndex,
    );
  }

}