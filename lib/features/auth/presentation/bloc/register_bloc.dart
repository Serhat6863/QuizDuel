import 'package:bloc/bloc.dart';
import 'package:quizduel/features/auth/data/repository/user_repository_impl.dart';
import 'package:quizduel/features/auth/domain/repository/user_repository.dart';
import 'package:quizduel/features/auth/presentation/bloc/register_event.dart';
import 'package:quizduel/features/auth/presentation/bloc/register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState>{
  final UserRepository userRepository;

  RegisterBloc({required this.userRepository}) : super(RegisterState.initial()){
    on<RegisterButtonPressed>(_registerButtonPressed);
  }


  Future<void> _registerButtonPressed(RegisterButtonPressed event , Emitter<RegisterState> emit) async{
    emit(RegisterState.loading());
    try{
      final result = await userRepository.register(event.email, event.password, event.username);

      emit(RegisterState.success());

    }catch(e){
      emit(RegisterState.failure(e.toString()));
    }
  }
}