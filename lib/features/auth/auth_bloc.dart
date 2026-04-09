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
    on<AuthLoadingEvent>((event, emit) => emit(AuthLoading()));
    on<RegistrationSuccessEvent>((event, emit) => emit(RegistrationSuccess()));
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
      add(AuthLoadingEvent());
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
      print('🔵 Intentando registrar usuario: $email');
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        //emailRedirectTo: 'http://localhost:3000/thank-you.html', // Para desarrollo local
        emailRedirectTo: 'https://jadrdev.github.io/gasolineras_can/thank-you.html', // Para producción
      );
      print('✅ Respuesta de registro: ${response.user?.id}');
      print('📧 Email confirmado: ${response.user?.emailConfirmedAt}');
      
      if (response.user != null) {
        print('✅ Usuario creado exitosamente');
        add(RegistrationSuccessEvent());
      }
    } on AuthException catch (e) {
      print('❌ Error de autenticación: ${e.message}');
      print('❌ Código de error: ${e.statusCode}');
      
      // Manejar error específico de envío de email
      if (e.message.contains('Error sending confirmation email') || 
          e.statusCode == '500') {
        add(AuthErrorEvent(
          'No se pudo enviar el email de confirmación. '
          'Por favor, contacta al administrador o desactiva la confirmación por email en Supabase. '
          'Dashboard → Authentication → Providers → Email → Deshabilitar "Enable email confirmations"'
        ));
      } else {
        add(AuthErrorEvent('Error: ${e.message}'));
      }
    } catch (e) {
      print('❌ Error inesperado: $e');
      add(AuthErrorEvent("Error inesperado: $e"));
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}
