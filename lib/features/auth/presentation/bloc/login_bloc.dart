import 'package:bloc/bloc.dart';
import 'package:quizduel/core/error/app_failure.dart';
import 'package:quizduel/features/auth/domain/repository/user_repository.dart';
import 'package:quizduel/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quizduel/features/auth/presentation/bloc/auth_event.dart';
import 'package:quizduel/features/auth/presentation/bloc/login_event.dart';
import 'package:quizduel/features/auth/presentation/bloc/login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {

  final UserRepository userRepository;
  final AuthBloc authBloc;

  LoginBloc({required this.userRepository, required this.authBloc}) : super(LoginState.initial()){
    on<LoginButtonPressed>(_loginButtonPressed);
  }


  Future<void> _loginButtonPressed(LoginButtonPressed event , Emitter<LoginState> emit) async{
    emit(LoginState.loading());
    try{
      final result = await userRepository.signIn(event.email, event.password);

      authBloc.add(LoggedIn());

      emit(LoginState.success());

    }catch(e){
      final errorMessage = e is AppFailure ?
      e.message
      : "An unknown error occurred during login.";

      emit(LoginState.failure(errorMessage));
    }
  }
}