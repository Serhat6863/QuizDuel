import 'package:equatable/equatable.dart';

abstract class QuizEvent extends Equatable{
  @override
  List<Object?> get props => [];
}


class FetchQuizEvent extends QuizEvent{
  final String category;
  final String difficulty;
  final int amount ;

  FetchQuizEvent({
    this.category = "",
    this.difficulty = "",
    this.amount = 10,
  });

  @override
  List<Object?> get props => [category, difficulty];
}