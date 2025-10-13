import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:quizduel/features/game/domain/entity/quiz_entity.dart';
import 'package:quizduel/features/game/domain/repository/quiz_repository.dart';
import 'package:quizduel/features/game/presentation/bloc/quiz_bloc.dart';
import 'package:quizduel/features/game/presentation/bloc/quiz_event.dart';
import 'package:quizduel/features/game/presentation/bloc/quiz_state.dart';

// Mock du repository
class MockQuizRepository extends Mock implements QuizRepository {}

void main() {
  late MockQuizRepository mockRepo;
  late QuizBloc quizBloc;

  final mockQuizzes = [
    QuizEntity(
      category: 'Science',
      difficulty: 'easy',
      question: 'What is H2O?',
      options: ['Oxygen', 'Water', 'Hydrogen'],
      correctAnswerIndex: 1,
    ),
  ];

  setUp(() {
    mockRepo = MockQuizRepository();
    quizBloc = QuizBloc(quizRepository: mockRepo);
  });

  tearDown(() => quizBloc.close());

  // ✅ Succès normal
  blocTest<QuizBloc, QuizState>(
    '🧪 emits [loading, loaded] when quizzes are fetched successfully',
    build: () {
      when(() => mockRepo.fetchQuizzes(
        amount: any(named: 'amount'),
        category: any(named: 'category'),
        difficulty: any(named: 'difficulty'),
      )).thenAnswer((_) async => mockQuizzes);
      return quizBloc;
    },
    act: (bloc) =>
        bloc.add(FetchQuizEvent(amount: 5, category: 'Science', difficulty: 'easy')),
    expect: () => [
      isA<QuizState>().having((s) => s.status, 'status', QuizStatus.loading),
      isA<QuizState>()
          .having((s) => s.status, 'status', QuizStatus.loaded)
          .having((s) => s.quizzes.length, 'quizzes count', 1),
    ],
    verify: (_) {
      verify(() => mockRepo.fetchQuizzes(
        amount: 5,
        category: 'Science',
        difficulty: 'easy',
      )).called(1);
    },
  );

  // ✅ Cas d’erreur — corrigé
  blocTest<QuizBloc, QuizState>(
    '🧪 emits [loading, error] when repository throws exception',
    build: () {
      when(() => mockRepo.fetchQuizzes(
        amount: any(named: 'amount'),
        category: any(named: 'category'),
        difficulty: any(named: 'difficulty'),
      )).thenAnswer((_) async => throw Exception('API Error')); // ✅ correction ici
      return quizBloc;
    },
    act: (bloc) => bloc.add(FetchQuizEvent(amount: 5)),
    expect: () => [
      isA<QuizState>().having((s) => s.status, 'status', QuizStatus.loading),
      isA<QuizState>().having((s) => s.status, 'status', QuizStatus.error),
    ],
  );

  // ✅ Aucun quiz trouvé
  blocTest<QuizBloc, QuizState>(
    '🧪 emits [loading, error] when repository returns empty list',
    build: () {
      when(() => mockRepo.fetchQuizzes(
        amount: any(named: 'amount'),
        category: any(named: 'category'),
        difficulty: any(named: 'difficulty'),
      )).thenAnswer((_) async => []);
      return quizBloc;
    },
    act: (bloc) => bloc.add(FetchQuizEvent(amount: 3)),
    expect: () => [
      isA<QuizState>().having((s) => s.status, 'status', QuizStatus.loading),
      isA<QuizState>()
          .having((s) => s.status, 'status', QuizStatus.error)
          .having((s) => s.message, 'message', 'No quizzes found'),
    ],
  );
}
