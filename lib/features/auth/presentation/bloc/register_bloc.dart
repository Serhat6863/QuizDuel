import 'package:bloc/bloc.dart';
import 'package:quizduel/core/error/app_failure.dart';
import 'package:quizduel/features/auth/domain/repository/user_repository.dart';
import 'package:quizduel/features/auth/presentation/bloc/register_event.dart';
import 'package:quizduel/features/auth/presentation/bloc/register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState>{
  final UserRepository userRepository;

  RegisterBloc({required this.userRepository}) : super(RegisterState.initial()){
    on<RegisterButtonPressed>(_registerButtonPressed);
    on<ResentEmailVerification>(_resentEmailVerification);
    on<CheckEmailVerified>(_checkEmailVerified);
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


  Future<void> _resentEmailVerification(ResentEmailVerification event , Emitter<RegisterState> emit) async{
    try{
      await userRepository.resentEmailVerification();
      emit(RegisterState.resentEmail());
    }catch(e){
      emit(RegisterState.failure(e.toString()));
    }
  }


  Future<void> _checkEmailVerified(CheckEmailVerified event , Emitter<RegisterState> emit) async{
    try{

      final isVerified = await userRepository.checkEmailVerified();
      if(isVerified){
        emit(RegisterState.success());
      }else{
        emit(RegisterState.notVerified());
      }

    }catch(e){
      emit(RegisterState.failure(e.toString()));
    }
  }
}