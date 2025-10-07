import 'quiz_model.dart';

class QuizResponseModel {
  final int responseCode;
  final List<QuizModel> results;

  QuizResponseModel({
    required this.responseCode,
    required this.results,
  });

  factory QuizResponseModel.fromJson(Map<String, dynamic> json) {
    final resultsList = (json['results'] as List<dynamic>?)
        ?.map((e) => QuizModel.fromJson(e as Map<String, dynamic>))
        .toList() ??
        [];

    return QuizResponseModel(
      responseCode: json['response_code'] ?? 0,
      results: resultsList,
    );
  }

  Map<String, dynamic> toJson() => {
    'response_code': responseCode,
    'results': results.map((e) => e.toJson()).toList(),
  };
}
