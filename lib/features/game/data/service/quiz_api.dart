import 'package:quizduel/features/game/data/model/quiz_response_model.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';


part 'quiz_api.g.dart';

@RestApi(baseUrl: "https://opentdb.com/")
abstract class QuizApi{
  factory QuizApi(Dio dio) = _QuizApi;

  @GET("/api.php")
  Future<HttpResponse<QuizResponseModel>> fetchQuizzes({
    @Query("amount") int amount = 10,
    @Query("category") String category = '',
    @Query("difficulty") String difficulty = '',
    @Query("type") String type = 'multiple',
  });

}