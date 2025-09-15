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
  final String message;

  LoginState({required this.status , required this.message});


  factory LoginState.initial() => LoginState(
    status: LoginStatus.initial,
    message: '',
  );

  factory LoginState.loading() => LoginState(
    status: LoginStatus.loading,
    message: '',
  );

  factory LoginState.success() => LoginState(
    status: LoginStatus.success,
    message: '',
  );

  factory LoginState.failure(String message) => LoginState(
    status: LoginStatus.failure,
    message: message,
  );

  LoginState copyWith({
    LoginStatus? status,
    String? message,
  }) {
    return LoginState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }


  List<Object?> get props => [status, message];
}