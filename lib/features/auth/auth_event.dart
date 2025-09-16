part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

/// Se dispara al arrancar la app, para comprobar si hay usuario logueado
class AuthStarted extends AuthEvent {}

class AuthLoggedIn extends AuthEvent {}

class AuthLoggedOut extends AuthEvent {}

/// Evento para propagar errores desde el BLoC a la UI
class AuthErrorEvent extends AuthEvent {
  final String message;
  const AuthErrorEvent(this.message);

  @override
  List<Object?> get props => [message];
}
