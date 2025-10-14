import 'package:equatable/equatable.dart';

abstract class RegisterEvent extends Equatable {
  @override
  List<Object?> get props => [];
}


class RegisterButtonPressed extends RegisterEvent{
  final String email;
  final String password;
  final String username;

  RegisterButtonPressed({required this.email, required this.password, required this.username});

  @override
  List<Object?> get props => [email, password, username];
}


class ResentEmailVerification extends RegisterEvent{}

class CheckEmailVerified extends RegisterEvent{}