import 'package:quizduel/core/error/app_failure.dart';

enum RegisterStatus { initial, loading, success, failure }


extension RegisterStatusX on RegisterStatus {
  bool get isInitial => this == RegisterStatus.initial;
  bool get isLoading => this == RegisterStatus.loading;
  bool get isSuccess => this == RegisterStatus.success;
  bool get isFailure => this == RegisterStatus.failure;
}


class RegisterState {
  final RegisterStatus status;
  final AppFailure? failure;

  RegisterState({required this.status, this.failure});

  factory RegisterState.initial() => RegisterState(
        status: RegisterStatus.initial,

      );

  factory RegisterState.loading() => RegisterState(
        status: RegisterStatus.loading,

      );

  factory RegisterState.success() => RegisterState(
        status: RegisterStatus.success,

      );

  factory RegisterState.failure(AppFailure failure) => RegisterState(
        status: RegisterStatus.failure,
        failure: failure,
      );

  RegisterState copyWith({
    RegisterStatus? status,
    AppFailure? failure,
  }) {
    return RegisterState(
      status: status ?? this.status,
      failure: failure ?? this.failure,
    );
  }

  List<Object?> get props => [status, failure];
}