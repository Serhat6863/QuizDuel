import 'package:bloc/bloc.dart';
import 'package:quizduel/features/auth/data/repository/user_repository_impl.dart';
import 'package:quizduel/features/auth/domain/repository/user_repository.dart';
import 'package:quizduel/features/auth/presentation/bloc/login_event.dart';
import 'package:quizduel/features/auth/presentation/bloc/login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {

  final UserRepository userRepository;

  LoginBloc({required this.userRepository}) : super(LoginState.initial()){
    on<LoginButtonPressed>(_loginButtonPressed);
  }


  Future<void> _loginButtonPressed(LoginButtonPressed event , Emitter<LoginState> emit) async{
    emit(LoginState.loading());
    try{
      final result = await userRepository.signIn(event.email, event.password);

      emit(LoginState.success());

    }catch(e){
      emit(LoginState.failure(e.toString()));
    }
  }


}