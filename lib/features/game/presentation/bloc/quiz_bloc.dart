import 'package:bloc/bloc.dart';
import 'package:quizduel/features/game/domain/repository/quiz_repository.dart';
import 'package:quizduel/features/game/presentation/bloc/quiz_event.dart';
import 'package:quizduel/features/game/presentation/bloc/quiz_state.dart';

import '../../../../core/utils/logger.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState>{

  final QuizRepository quizRepository;

  QuizBloc({required this.quizRepository}) : super(QuizState.initial()){
    on<FetchQuizEvent>(_fetchQuizzes);
  }


  Future<void> _fetchQuizzes(FetchQuizEvent event, Emitter<QuizState> emit) async{
    logger.i("Récupération des quiz");
    emit(QuizState.loading());
    try{
      final quizzes = await quizRepository.fetchQuizzes(amount: event.amount, category: event.category, difficulty: event.difficulty);
      if(quizzes.isEmpty){
        logger.w("Aucun quiz trouvé");
        emit(QuizState.error("No quizzes found"));
      }else{
        logger.d("Récupération des quiz : ${quizzes.length}");
        emit(QuizState.loaded(quizzes));
      }
    }catch(e){
      logger.e("Erreur lors de la récupération des quiz: $e");
      emit(QuizState.error(e.toString()));
    }
  }
}