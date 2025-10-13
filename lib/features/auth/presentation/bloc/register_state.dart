import 'package:equatable/equatable.dart';

enum RegisterStatus {
  initial,
  loading,
  success,
  failure,
}

extension RegisterStatusX on RegisterStatus {
  bool get isInitial => this == RegisterStatus.initial;
  bool get isLoading => this == RegisterStatus.loading;
  bool get isSuccess => this == RegisterStatus.success;
  bool get isFailure => this == RegisterStatus.failure;
}

class RegisterState extends Equatable {
  final RegisterStatus status;
  final String? failure; // 🔥 remplacé AppFailure par String

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

  factory RegisterState.failure(String message) => RegisterState(
    status: RegisterStatus.failure,
    failure: message,
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
