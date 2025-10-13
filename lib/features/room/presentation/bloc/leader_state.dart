import 'package:equatable/equatable.dart';
import 'package:quizduel/features/auth/domain/entity/user_entity.dart';

enum LeaderStatus {
  initial,
  loading,
  success,
  failure,
}

extension LeaderStatusX on LeaderStatus {
  bool get isInitial => this == LeaderStatus.initial;
  bool get isLoading => this == LeaderStatus.loading;
  bool get isSuccess => this == LeaderStatus.success;
  bool get isFailure => this == LeaderStatus.failure;
}

class LeaderState extends Equatable {
  final LeaderStatus status;
  final List<UserEntity> leaders;
  final String? errorMessage;

  const LeaderState({
    this.status = LeaderStatus.initial,
    this.leaders = const [],
    this.errorMessage,
  });

  factory LeaderState.initial() => const LeaderState();
  factory LeaderState.loading() => const LeaderState(status: LeaderStatus.loading);
  factory LeaderState.success(List<UserEntity> leaders) => LeaderState(status: LeaderStatus.success, leaders: leaders);
  factory LeaderState.failure(String errorMessage) => LeaderState(status: LeaderStatus.failure, errorMessage: errorMessage);

  LeaderState copyWith({
    LeaderStatus? status,
    List<UserEntity>? leaders,
    String? errorMessage,
  }) {
    return LeaderState(
      status: status ?? this.status,
      leaders: leaders ?? this.leaders,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, leaders, errorMessage];
}
