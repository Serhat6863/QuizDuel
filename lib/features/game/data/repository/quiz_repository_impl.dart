import 'package:quizduel/core/utils/logger.dart';
import 'package:quizduel/features/game/data/service/quiz_api.dart';
import 'package:quizduel/features/game/domain/entity/quiz_entity.dart';
import 'package:quizduel/features/game/domain/repository/quiz_repository.dart';

class QuizRepositoryImpl implements QuizRepository{

  final QuizApi quizApi;

  QuizRepositoryImpl({required this.quizApi});

  @override
  Future<List<QuizEntity>> fetchQuizzes({int amount = 10, String category = '', String difficulty = ''}) async {
    try {
      final response = await quizApi.fetchQuizzes(amount: amount, category: category, difficulty: difficulty);

      if(response.response.statusCode != 200){
        logger.e("Erreur lors de la récupération des quiz: ${response.response.statusCode}");
        throw Exception("Erreur lors de la récupération des quiz: ${response.response.statusCode}");
      }


      final quizResponseModel = response.data;

      return quizResponseModel.results.map((e) => e.toEntity()).toList();

    } catch (e) {
      logger.e("Erreur lors de la récupération des quiz: $e");
      throw Exception("Erreur lors de la récupération des quiz: $e");

    }
  }



}