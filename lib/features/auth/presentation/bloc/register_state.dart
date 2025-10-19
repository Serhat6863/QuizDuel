import 'package:equatable/equatable.dart';

enum RegisterStatus {
  initial,
  loading,
  success,
  failure,
  resentEmail,
  notVerified,
}

extension RegisterStatusX on RegisterStatus {
  bool get isInitial => this == RegisterStatus.initial;
  bool get isLoading => this == RegisterStatus.loading;
  bool get isSuccess => this == RegisterStatus.success;
  bool get isFailure => this == RegisterStatus.failure;
  bool get isResentEmail => this == RegisterStatus.resentEmail;
  bool get isNotVerified => this == RegisterStatus.notVerified;
}

class RegisterState extends Equatable {
  final RegisterStatus status;
  final String? failure;

  const RegisterState({
    required this.status,
    this.failure,
  });

  // 🔹 Factories
  factory RegisterState.initial() => const RegisterState(
    status: RegisterStatus.initial,
  );

  factory RegisterState.loading() => const RegisterState(
    status: RegisterStatus.loading,
  );

  factory RegisterState.success() => const RegisterState(
    status: RegisterStatus.success,
  );

  factory RegisterState.notVerified() => const RegisterState(
    status: RegisterStatus.notVerified,
  );

  factory RegisterState.failure(String message) => RegisterState(
    status: RegisterStatus.failure,
    failure: message,
  );

  factory RegisterState.resentEmail() => const RegisterState(
    status: RegisterStatus.resentEmail,
  );

  // 🔹 copyWith
  RegisterState copyWith({
    RegisterStatus? status,
    String? failure,
  }) {
    return RegisterState(
      status: status ?? this.status,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [status, failure];
}
