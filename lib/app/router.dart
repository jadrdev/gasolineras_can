import 'package:material_ui/material_ui.dart';
import 'package:gasolineras_can/core/enlaces.dart';
import 'package:gasolineras_can/core/splash_screen.dart';
import 'package:gasolineras_can/core/widgets/margen_lateral.dart';
import 'package:gasolineras_can/features/auth/auth_bloc.dart';
import 'package:gasolineras_can/features/auth/presentacion.dart';
import 'package:gasolineras_can/features/home/home_scree.dart';
import 'package:gasolineras_can/features/guide/guide_page.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

/// A ChangeNotifier that listens to a Stream and notifies listeners when the stream emits a value.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: '/home',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final loggedIn = authBloc.state is Authenticated;
      final currentPath = state.uri.toString();
      final isAuthPage = currentPath == '/login' || currentPath == '/register';

      // Si está logueado y está en una página de autenticación, redirigir a home
      if (loggedIn && isAuthPage) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const MargenLateral(child: LoginScreen()),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const MargenLateral(child: RegisterScreen()),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      // Enlace gasocan://app/electricos (evento del App Store).
      GoRoute(
        path: '/electricos',
        redirect: (context, state) {
          Enlaces.pedirElectricos();
          return '/home';
        },
      ),
      GoRoute(
        path: '/guide',
        builder: (context, state) =>
            GuidePage(firstLaunch: state.uri.queryParameters['first'] == '1'),
      ),
    ],
  );
}
