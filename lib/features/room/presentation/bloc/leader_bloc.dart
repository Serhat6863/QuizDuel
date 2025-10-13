import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizduel/features/auth/domain/repository/user_repository.dart';
import 'package:quizduel/features/room/presentation/bloc/leader_event.dart';
import 'package:quizduel/features/room/presentation/bloc/leader_state.dart';

class LeaderBloc extends Bloc<LeaderEvent, LeaderState> {
  final UserRepository userRepository;

  LeaderBloc({required this.userRepository}) : super(LeaderState.initial()) {
    on<FetchLeaderBoardEvent>(_onFetchLeaderBoard);
  }


  Future<void> _onFetchLeaderBoard(FetchLeaderBoardEvent event, Emitter<LeaderState> emit) async {
    emit(LeaderState.loading());
    try {
      final users = await userRepository.getAllUsers();
      users.sort((a, b) => (b.score ?? 0).compareTo(a.score ?? 0)); // trier par score décroissant
      emit(LeaderState.success(users));
    } catch (e) {
      emit(LeaderState.failure("Erreur lors du chargement du classement: ${e.toString()}"));
    }
  }





}