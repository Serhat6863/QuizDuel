import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

import 'package:quizduel/features/game/data/model/quiz_model.dart';
import 'package:quizduel/features/game/data/model/quiz_response_model.dart';
import 'package:quizduel/features/game/data/repository/quiz_repository_impl.dart';
import 'package:quizduel/features/game/data/service/quiz_api.dart';
import 'package:quizduel/features/game/domain/entity/quiz_entity.dart';

class MockQuizApi extends Mock implements QuizApi {}

void main() {
  late MockQuizApi mockApi;
  late QuizRepositoryImpl repo;

  setUp(() {
    mockApi = MockQuizApi();
    repo = QuizRepositoryImpl(quizApi: mockApi);
  });

  group('QuizRepositoryImpl.fetchQuizzes', () {
    test('✅ returns List<QuizEntity> on 200 with content', () async {
      // Crée un QuizResponseModel simulé
      final quiz = QuizModel(
        category: 'Science',
        difficulty: 'easy',
        question: 'What is H2O?',
        options: ['Oxygen', 'Water', 'Hydrogen', 'Helium'],
        correctAnswerIndex: 1,
      );

      final quizResponse = QuizResponseModel(responseCode: 0, results: [quiz]);

      // Crée une vraie instance HttpResponse<QuizResponseModel>
      final fakeHttpResponse = HttpResponse(
        quizResponse,
        Response(
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      when(() => mockApi.fetchQuizzes(
        amount: any(named: 'amount'),
        category: any(named: 'category'),
        difficulty: any(named: 'difficulty'),
      )).thenAnswer((_) async => fakeHttpResponse);

      final result = await repo.fetchQuizzes(amount: 5);

      expect(result, isA<List<QuizEntity>>());
      expect(result.length, 1);
      expect(result.first.question, 'What is H2O?');
    });

    test('🚫 throws on non-200 status code', () async {
      final fakeHttpResponse = HttpResponse(
        QuizResponseModel(responseCode: 1, results: []),
        Response(
          statusCode: 500,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      when(() => mockApi.fetchQuizzes(
        amount: any(named: 'amount'),
        category: any(named: 'category'),
        difficulty: any(named: 'difficulty'),
      )).thenAnswer((_) async => fakeHttpResponse);

      expect(
            () => repo.fetchQuizzes(),
        throwsA(isA<Object>()),
      );
    });

    test('💥 rethrows when QuizApi throws', () async {
      when(() => mockApi.fetchQuizzes(
        amount: any(named: 'amount'),
        category: any(named: 'category'),
        difficulty: any(named: 'difficulty'),
      )).thenThrow(Exception('network down'));

      expect(
            () => repo.fetchQuizzes(amount: 3),
        throwsA(isA<Exception>()),
      );
    });

    test('🟡 returns empty list when 200 with empty results', () async {
      final fakeHttpResponse = HttpResponse(
        QuizResponseModel(responseCode: 0, results: []),
        Response(
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      when(() => mockApi.fetchQuizzes(
        amount: any(named: 'amount'),
        category: any(named: 'category'),
        difficulty: any(named: 'difficulty'),
      )).thenAnswer((_) async => fakeHttpResponse);

      final result = await repo.fetchQuizzes(amount: 2);

      expect(result, isEmpty);
    });
  });
}
