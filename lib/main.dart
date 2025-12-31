import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/router.dart';
import 'features/auth/auth_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  final authBloc = AuthBloc();

  runApp(
    BlocProvider.value(
      value: authBloc,
      child: MyApp(authBloc: authBloc),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthBloc authBloc;
  const MyApp({super.key, required this.authBloc});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Gasolineras de Canarias',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.beVietnamProTextTheme(),
      ),
      routerConfig: createRouter(authBloc),
    );
  }
}
