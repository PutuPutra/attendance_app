import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {
  final String username;
  final String password;
  final bool isBiometric;

  const LoginRequested({
    required this.username,
    required this.password,
    this.isBiometric = false,
  });

  @override
  List<Object> get props => [username, password, isBiometric];
}

class LogoutRequested extends AuthEvent {}

class ForgotPasswordRequested extends AuthEvent {
  final String username;

  const ForgotPasswordRequested(this.username);

  @override
  List<Object> get props => [username];
}
