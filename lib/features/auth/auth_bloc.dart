// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';


part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth;

  AuthBloc({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      super(AuthInitial()) {
    // Registrar handlers primero para que `add(...)` pueda usarse en la
    // suscripción sin lanzar StateError.
    on<AuthLoggedIn>((event, emit) => emit(Authenticated()));
    on<AuthLoggedOut>((event, emit) => emit(Unauthenticated()));
    on<AuthErrorEvent>((event, emit) => emit(AuthError(event.message)));

    // Detectar cambios de usuario después de registrar handlers
    _firebaseAuth.authStateChanges().listen((user) {
      if (user != null) {
        add(AuthLoggedIn());
      } else {
        add(AuthLoggedOut());
      }
    });
  }

  // Método para login
  Future<void> login({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      // Manejo más específico para errores de Firebase Auth
      if (e is FirebaseAuthException) {
        final message = _mapFirebaseAuthError(e);
        add(AuthErrorEvent(message));
      } else {
        final message = 'Error inesperado al iniciar sesión';
        add(AuthErrorEvent(message));
      }
    }
  }

  Future<void> register({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      if (e is FirebaseAuthException) {
        final message = _mapFirebaseAuthError(e);
        add(AuthErrorEvent(message));
      } else {
        final message = 'Error inesperado al registrarse';
        add(AuthErrorEvent(message));
      }
    }
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
      case 'invalid-argument':
        return 'Credenciales inválidas o caducadas. Por favor inténtalo de nuevo.';
      case 'user-not-found':
        return 'No existe una cuenta con ese correo.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'user-disabled':
        return 'La cuenta ha sido deshabilitada.';
      case 'email-already-in-use':
        return 'El correo ya está en uso.';
      case 'weak-password':
        return 'La contraseña es demasiado débil.';
      case 'network-request-failed':
        return 'Error de red. Revisa tu conexión.';
      default:
        return e.message ?? 'Error de autenticación';
    }
  }

  // Método para logout
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}
