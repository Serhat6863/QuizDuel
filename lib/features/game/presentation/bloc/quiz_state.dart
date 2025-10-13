import 'package:equatable/equatable.dart';
import 'package:quizduel/features/game/domain/entity/quiz_entity.dart';

enum QuizStatus{
  initial,
  loading,
  loaded,
  error
}

extension QuizStatusX on QuizStatus{
  bool get isInitial => this == QuizStatus.initial;
  bool get isLoading => this == QuizStatus.loading;
  bool get isLoaded => this == QuizStatus.loaded;
  bool get isError => this == QuizStatus.error;
}

class QuizState extends Equatable{
  final QuizStatus status;
  final String? message;
  final List<QuizEntity> quizzes;

  const QuizState({
    required this.status,
    this.message,
    required this.quizzes,
  });

  factory QuizState.initial() => QuizState(
    status: QuizStatus.initial,
    quizzes: [],
  );

  factory QuizState.loading() => QuizState(
    status: QuizStatus.loading,
    quizzes: [],
  );

  factory QuizState.loaded(List<QuizEntity> quizzes) => QuizState(
    status: QuizStatus.loaded,
    quizzes: quizzes,
  );

  factory QuizState.error(String message) => QuizState(
    status: QuizStatus.error,
    message: message,
    quizzes: [],
  );

  QuizState copyWith({
    QuizStatus? status,
    String? message,
    List<QuizEntity>? quizzes,
  }) {
    return QuizState(
      status: status ?? this.status,
      message: message ?? this.message,
      quizzes: quizzes ?? this.quizzes,
    );
  }

  @override
  List<Object?> get props => [status, message, quizzes];


}