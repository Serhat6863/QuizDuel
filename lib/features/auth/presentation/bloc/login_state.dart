import 'package:equatable/equatable.dart';

enum LoginStatus {
  initial,
  loading,
  success,
  failure,
}

extension LoginStatusX on LoginStatus {
  bool get isInitial => this == LoginStatus.initial;
  bool get isLoading => this == LoginStatus.loading;
  bool get isSuccess => this == LoginStatus.success;
  bool get isFailure => this == LoginStatus.failure;
}

class LoginState extends Equatable {
  final LoginStatus status;
  final String? failure; // 🔥 remplacé AppFailure par String

  const LoginState({
    required this.status,
    this.failure,
  });

  // 🔹 Factories
  factory LoginState.initial() => const LoginState(
    status: LoginStatus.initial,
  );

  factory LoginState.loading() => const LoginState(
    status: LoginStatus.loading,
  );

  factory LoginState.success() => const LoginState(
    status: LoginStatus.success,
  );

  factory LoginState.failure(String message) => LoginState(
    status: LoginStatus.failure,
    failure: message,
  );

  // 🔹 copyWith
  LoginState copyWith({
    LoginStatus? status,
    String? failure,
  }) {
    return LoginState(
      status: status ?? this.status,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [status, failure];
}
