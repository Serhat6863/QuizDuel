import 'package:quizduel/features/game/domain/entity/quiz_entity.dart';

abstract class QuizRepository {
  Future<List<QuizEntity>> fetchQuizzes({int amount = 10, String category = '' , String difficulty = ''});
}