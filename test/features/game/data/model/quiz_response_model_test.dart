import 'package:flutter_test/flutter_test.dart';
import 'package:quizduel/features/game/data/model/quiz_model.dart';
import 'package:quizduel/features/game/data/model/quiz_response_model.dart';

void main() {
  group('QuizResponseModel', () {
    test('fromJson() should parse correctly', () {
      final json = {
        'response_code': 0,
        'results': [
          {
            'category': 'Science',
            'difficulty': 'easy',
            'question': 'What is water?',
            'correct_answer': 'H2O',
            'incorrect_answers': ['O2', 'CO2', 'He'],
          }
        ]
      };

      final model = QuizResponseModel.fromJson(json);

      expect(model.responseCode, 0);
      expect(model.results.length, 1);
      expect(model.results.first.question, 'What is water?');
    });

    test('toJson() should serialize correctly', () {
      final quiz = QuizModel(
        category: 'History',
        difficulty: 'medium',
        question: 'Who was Napoleon?',
        options: ['King', 'General', 'Scientist'],
        correctAnswerIndex: 1,
      );

      final response = QuizResponseModel(responseCode: 0, results: [quiz]);

      final json = response.toJson();
      expect(json['response_code'], 0);
      expect((json['results'] as List).length, 1);
      expect(json['results'][0]['question'], 'Who was Napoleon?');
    });
  });
}
