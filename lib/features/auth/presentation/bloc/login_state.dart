import 'package:quizduel/core/error/app_failure.dart';

enum LoginStatus{
  initial,
  loading,
  success,
  failure
}


extension LoginStatusX on LoginStatus{
  bool get isInitial => this == LoginStatus.initial;
  bool get isLoading => this == LoginStatus.loading;
  bool get isSuccess => this == LoginStatus.success;
  bool get isFailure => this == LoginStatus.failure;
}


class LoginState{
  final LoginStatus status;
  final AppFailure? failure;

  LoginState({required this.status , this.failure});


  factory LoginState.initial() => LoginState(
    status: LoginStatus.initial,
  );

  factory LoginState.loading() => LoginState(
    status: LoginStatus.loading,

  );

  factory LoginState.success() => LoginState(
    status: LoginStatus.success,

  );

  factory LoginState.failure(AppFailure failure) => LoginState(
    status: LoginStatus.failure,
    failure: failure,
  );

  LoginState copyWith({
    LoginStatus? status,
    AppFailure? failure,
  }) {
    return LoginState(
      status: status ?? this.status,
      failure: failure ?? this.failure
    );
  }


  List<Object?> get props => [status, failure];
}