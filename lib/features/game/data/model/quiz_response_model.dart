import 'package:quizduel/features/game/data/model/quiz_model.dart';

class QuizResponseModel {
  final int responseCode;
  final List<QuizModel> results;

  const QuizResponseModel({
    required this.responseCode,
    required this.results,
  });

  factory QuizResponseModel.fromJson(Map<String, dynamic> json) {
    return QuizResponseModel(
      responseCode: json['response_code'] as int? ?? 0,
      results: (json['results'] as List<dynamic>?)
          ?.map((e) => QuizModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'response_code': responseCode,
    'results': results.map((e) => e.toJson()).toList(),
  };
}
