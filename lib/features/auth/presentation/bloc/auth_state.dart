import 'package:quizduel/core/error/app_failure.dart';
import 'package:quizduel/features/auth/domain/entity/user_entity.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
  failure,
}

extension AuthStatusX on AuthStatus {
  bool get isInitial => this == AuthStatus.initial;
  bool get isAuthenticated => this == AuthStatus.authenticated;
  bool get isUnauthenticated => this == AuthStatus.unauthenticated;
  bool get isLoading => this == AuthStatus.loading;
  bool get isFailure => this == AuthStatus.failure;
}

class AuthState {
  final AuthStatus status;
  final UserEntity? user;
  final AppFailure? failure;

  const AuthState({
    required this.status,
    this.user,
    this.failure,
  });

  // Factories
  factory AuthState.initial() => const AuthState(status: AuthStatus.initial);

  factory AuthState.authenticated(UserEntity user) =>
      AuthState(status: AuthStatus.authenticated, user: user);

  factory AuthState.unauthenticated() =>
      const AuthState(status: AuthStatus.unauthenticated);

  factory AuthState.loading() =>
      const AuthState(status: AuthStatus.loading);

  factory AuthState.failure(AppFailure failure) =>
      AuthState(status: AuthStatus.failure, failure: failure);

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    AppFailure? failure,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      failure: failure ?? this.failure,
    );
  }

  List<Object?> get props => [status, user, failure];
}
