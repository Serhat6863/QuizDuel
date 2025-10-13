import 'package:flutter_test/flutter_test.dart';
import 'package:quizduel/features/game/data/model/quiz_model.dart';

void main() {
  group('QuizModel', () {
    test('fromJson() should parse OpenTrivia data correctly', () {
      final json = {
        'category': 'Science',
        'difficulty': 'easy',
        'question': 'What is H2O?',
        'correct_answer': 'Water',
        'incorrect_answers': ['Oxygen', 'Hydrogen', 'Carbon'],
      };

      final model = QuizModel.fromJson(json);

      expect(model.category, 'Science');
      expect(model.difficulty, 'easy');
      expect(model.question, 'What is H2O?');
      expect(model.options.length, 4);
      expect(model.options.contains('Water'), true);
      expect(model.correctAnswerIndex >= 0, true);
    });

    test('fromJson() should parse Firebase data correctly', () {
      final json = {
        'category': 'Math',
        'difficulty': 'medium',
        'question': '2 + 2 = ?',
        'options': ['3', '4', '5'],
        'correctAnswerIndex': 1,
      };

      final model = QuizModel.fromJson(json);
      expect(model.category, 'Math');
      expect(model.difficulty, 'medium');
      expect(model.options, ['3', '4', '5']);
      expect(model.correctAnswerIndex, 1);
    });

    test('toJson() should return correct map', () {
      final model = QuizModel(
        category: 'History',
        difficulty: 'hard',
        question: 'Who discovered America?',
        options: ['Columbus', 'Vikings', 'Chinese'],
        correctAnswerIndex: 0,
      );

      final json = model.toJson();
      expect(json['category'], 'History');
      expect(json['difficulty'], 'hard');
      expect(json['options'], ['Columbus', 'Vikings', 'Chinese']);
      expect(json['correctAnswerIndex'], 0);
    });
  });
}
