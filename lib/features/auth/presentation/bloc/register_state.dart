enum RegisterStatus { initial, loading, success, failure }


extension RegisterStatusX on RegisterStatus {
  bool get isInitial => this == RegisterStatus.initial;
  bool get isLoading => this == RegisterStatus.loading;
  bool get isSuccess => this == RegisterStatus.success;
  bool get isFailure => this == RegisterStatus.failure;
}


class RegisterState {
  final RegisterStatus status;
  final String message;

  RegisterState({required this.status, required this.message});

  factory RegisterState.initial() => RegisterState(
        status: RegisterStatus.initial,
        message: '',
      );

  factory RegisterState.loading() => RegisterState(
        status: RegisterStatus.loading,
        message: '',
      );

  factory RegisterState.success() => RegisterState(
        status: RegisterStatus.success,
        message: '',
      );

  factory RegisterState.failure(String message) => RegisterState(
        status: RegisterStatus.failure,
        message: message,
      );

  RegisterState copyWith({
    RegisterStatus? status,
    String? message,
  }) {
    return RegisterState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  List<Object?> get props => [status, message];
}