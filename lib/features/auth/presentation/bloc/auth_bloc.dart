import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizduel/features/auth/domain/repository/user_repository.dart';
import 'package:quizduel/features/auth/presentation/bloc/auth_event.dart';
import 'package:quizduel/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState>{
  final UserRepository userRepository;

  AuthBloc({required this.userRepository}) : super(AuthState.initial()){
    on<LoggedOut>(_onSignOut);
    on<AppStarted>(_onAppStarted);
  }



  Future<void> _onSignOut(LoggedOut event , Emitter<AuthState> emit) async{
    emit(AuthState.loading());
    try{
      await userRepository.signOut();
      emit(AuthState.unauthenticated());
    }catch(e){
      emit(AuthState.failure(e.toString()));
    }
  }


  Future<void> _onAppStarted(AppStarted event , Emitter<AuthState> emit) async{
    emit(AuthState.loading());
    try{
      final user = await userRepository.getCurrentUser();
      if(user != null) {
        emit(AuthState.authenticated(user));
      }else{
        emit(AuthState.unauthenticated());
      }

    }catch(e){
      emit(AuthState.failure(e.toString()));
    }
  }


}