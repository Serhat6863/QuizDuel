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
  final String message;
  final UserEntity? user;

  const AuthState({
    required this.status,
    required this.message,
    this.user,
  });

  // Factories
  factory AuthState.initial() => const AuthState(
    status: AuthStatus.initial,
    message: '',
  );

  factory AuthState.authenticated(UserEntity user) => AuthState(
    status: AuthStatus.authenticated,
    message: '',
    user: user,
  );

  factory AuthState.unauthenticated() => const AuthState(
    status: AuthStatus.unauthenticated,
    message: '',
  );

  factory AuthState.loading() => const AuthState(
    status: AuthStatus.loading,
    message: '',
  );

  factory AuthState.failure(String message) => AuthState(
    status: AuthStatus.failure,
    message: message,
  );

  AuthState copyWith({
    AuthStatus? status,
    String? message,
    UserEntity? user,
  }) {
    return AuthState(
      status: status ?? this.status,
      message: message ?? this.message,
      user: user ?? this.user,
    );
  }

  List<Object?> get props => [status, message, user];
}
