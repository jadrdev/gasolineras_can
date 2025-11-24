import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  AuthBloc() : super(AuthInitial()) {
    // Handlers
    on<AuthLoggedIn>((event, emit) => emit(Authenticated()));
    on<AuthLoggedOut>((event, emit) => emit(Unauthenticated()));
    on<AuthErrorEvent>((event, emit) => emit(AuthError(event.message)));

    // Escuchar cambios de sesión
    _supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent eventType = data.event;
      final session = data.session;

      if (session != null && eventType == AuthChangeEvent.signedIn) {
        add(AuthLoggedIn());
      } else if (eventType == AuthChangeEvent.signedOut) {
        add(AuthLoggedOut());
      }
    });

    // Estado inicial según si hay sesión
    final hasSession = _supabase.auth.currentSession != null;
    if (hasSession) {
      add(AuthLoggedIn());
    } else {
      add(AuthLoggedOut());
    }
  }

  // LOGIN
  Future<void> login({required String email, required String password}) async {
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      add(AuthErrorEvent(e.message));
    } catch (_) {
      add(AuthErrorEvent("Error inesperado al iniciar sesión"));
    }
  }

  // REGISTER
  Future<void> register({
    required String email,
    required String password,
  }) async {
    try {
      await _supabase.auth.signUp(email: email, password: password);
    } on AuthException catch (e) {
      add(AuthErrorEvent(e.message));
    } catch (_) {
      add(AuthErrorEvent("Error inesperado al registrarse"));
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}
