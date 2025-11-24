part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthLoggedIn extends AuthEvent {}

class AuthLoggedOut extends AuthEvent {}

class AuthErrorEvent extends AuthEvent {
  final String message;
  const AuthErrorEvent(this.message);

  @override
  List<Object?> get props => [message];
}
