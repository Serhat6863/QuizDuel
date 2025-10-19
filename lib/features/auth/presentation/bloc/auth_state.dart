import 'package:equatable/equatable.dart';
import 'package:quizduel/features/auth/domain/entity/user_entity.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
  failure,
  deleted,
  passwordResetEmailSent,
}

extension AuthStatusX on AuthStatus {
  bool get isInitial => this == AuthStatus.initial;
  bool get isAuthenticated => this == AuthStatus.authenticated;
  bool get isUnauthenticated => this == AuthStatus.unauthenticated;
  bool get isLoading => this == AuthStatus.loading;
  bool get isFailure => this == AuthStatus.failure;
  bool get isDeleted => this == AuthStatus.deleted;
  bool get isPasswordResetEmailSent => this == AuthStatus.passwordResetEmailSent;
}

class AuthState extends Equatable {
  final AuthStatus status;
  final UserEntity? user;
  final String? failure; // <- maintenant c’est une simple String

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

  factory AuthState.loading() => const AuthState(status: AuthStatus.loading);

  factory AuthState.deleted() => const AuthState(status: AuthStatus.deleted);

  factory AuthState.passwordResetEmailSent() =>
      const AuthState(status: AuthStatus.passwordResetEmailSent);

  factory AuthState.failure(String message) =>
      AuthState(status: AuthStatus.failure, failure: message);

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? failure, // <- correction ici
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      failure: failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => [status, user, failure];
}
