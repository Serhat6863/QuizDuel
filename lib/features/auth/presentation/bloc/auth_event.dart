import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}

class LoggedIn extends AuthEvent {}

class LoggedOut extends AuthEvent {}

class RefreshUserEvent extends AuthEvent{}

class DeleteAccountEvent extends AuthEvent{}

class SendPasswordResetEmailEvent extends AuthEvent{
  final String email;

  SendPasswordResetEmailEvent(this.email);

  @override
  List<Object?> get props => [email];
}