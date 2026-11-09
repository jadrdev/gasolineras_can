import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/router.dart';
import 'core/notifications/notification_service.dart';
import 'core/notifications/push_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/auth_bloc.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Notificaciones locales (canal de Android y push con la app abierta)
  await NotificationService.init();

  // Push de bajada de precio: las decide el servidor (price-alerts) cada hora.
  // No bloquea el arranque: en iOS el token de APNs puede tardar un poco.
  unawaited(PushService.init());

  final authBloc = AuthBloc();
  final themeCubit = ThemeCubit();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authBloc),
        BlocProvider.value(value: themeCubit),
      ],
      child: MyApp(authBloc: authBloc),
    ),
  );
}

class MyApp extends StatefulWidget {
  final AuthBloc authBloc;
  const MyApp({super.key, required this.authBloc});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final _router = createRouter(widget.authBloc);
  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Gasolineras de Canarias',
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          routerConfig: _router,
        );
      },
    );
  }
}
