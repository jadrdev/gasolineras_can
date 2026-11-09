import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  StreamSubscription<dynamic>? _authSubscription;

  AuthBloc() : super(AuthInitial()) {
    // Handlers
    on<AuthLoggedIn>((event, emit) => emit(Authenticated()));
    on<AuthLoggedOut>((event, emit) => emit(Unauthenticated()));
    on<AuthLoadingEvent>((event, emit) => emit(AuthLoading()));
    on<RegistrationSuccessEvent>((event, emit) => emit(RegistrationSuccess()));
    on<AuthErrorEvent>((event, emit) => emit(AuthError(event.message)));

    // Escuchar cambios de sesión
    _authSubscription = _supabase.auth.onAuthStateChange.listen((data) {
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

  // APPLE (solo iOS): Apple da un identityToken y Supabase crea o recupera
  // la cuenta. El nonce evita que se reutilice un token interceptado:
  // a Apple se le pasa su SHA-256 y a Supabase el valor original.
  Future<void> signInWithApple() async {
    try {
      add(AuthLoadingEvent());
      final random = Random.secure();
      final rawNonce = base64Url.encode(
        List<int>.generate(32, (_) => random.nextInt(256)),
      );
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email],
        nonce: sha256.convert(utf8.encode(rawNonce)).toString(),
      );
      final idToken = credential.identityToken;
      if (idToken == null) {
        throw const AuthException('Apple no devolvió la identidad');
      }
      await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      // Cancelar el diálogo de Apple no es un error.
      if (e.code == AuthorizationErrorCode.canceled) {
        add(AuthLoggedOut());
      } else {
        add(AuthErrorEvent('No se pudo iniciar sesión con Apple'));
      }
    } on AuthException catch (e) {
      add(AuthErrorEvent('No se pudo iniciar sesión con Apple: ${e.message}'));
    } catch (_) {
      add(AuthErrorEvent('No se pudo iniciar sesión con Apple'));
    }
  }

  // REGISTER
  Future<void> register({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        //emailRedirectTo: 'http://localhost:3000/thank-you.html', // Para desarrollo local
        emailRedirectTo:
            'https://jadrdev.github.io/gasolineras_can/thank-you.html', // Para producción
      );

      if (response.user != null) {
        add(RegistrationSuccessEvent());
      }
    } on AuthException catch (e) {
      // Manejar error específico de envío de email
      if (e.message.contains('Error sending confirmation email') ||
          e.statusCode == '500') {
        add(
          AuthErrorEvent(
            'No se pudo enviar el email de confirmación. '
            'Vuelve a intentarlo más tarde.',
          ),
        );
      } else {
        add(AuthErrorEvent('Error: ${e.message}'));
      }
    } catch (e) {
      add(AuthErrorEvent("Error inesperado: $e"));
    }
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    return super.close();
  }

  // LOGOUT
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  // BORRAR CUENTA: la función delete_my_account (supabase/delete_my_account.sql)
  // borra favoritos, perfil y el usuario de auth. Lanza si el servidor falla.
  Future<void> deleteAccount() async {
    await _supabase.rpc('delete_my_account');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('priceAlertSnapshots');
    // El usuario ya no existe en el servidor: solo cerramos la sesión local.
    await _supabase.auth.signOut(scope: SignOutScope.local);
  }
}
