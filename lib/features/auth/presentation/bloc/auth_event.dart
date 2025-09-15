import 'package:equatable/equatable.dart';
import 'package:quizduel/features/auth/domain/entity/user_entity.dart';

abstract class AuthEvent extends Equatable{
  @override
  List<Object?> get props => [];
}


class AppStarted extends AuthEvent{}

class LoggedOut extends AuthEvent{}

class Authenticated extends AuthEvent{
  final bool isLoggedIn;

  Authenticated({required this.isLoggedIn});

  @override
  List<Object?> get props => [isLoggedIn];
}