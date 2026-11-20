import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import '../../core/widgets/ios_glass_navigation_bar.dart';
import '../../core/widgets/margen_lateral.dart';
import 'package:material_ui/material_ui.dart';
import 'package:gasolineras_can/features/auth/profile_page.dart';
import 'package:gasolineras_can/features/favoritos/favoritos_page.dart';
import 'package:gasolineras_can/features/gasolineras/presentacion/gas_station_list_page.dart';
import 'package:gasolineras_can/features/favoritos/data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:gasolineras_can/core/enlaces.dart';
import 'package:gasolineras_can/features/guide/guide_page.dart';
import 'package:gasolineras_can/l10n/l10n.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  FavoriteRepository _favorites = FavoriteRepository();
  String? _userId = Supabase.instance.client.auth.currentUser?.id;
  StreamSubscription<AuthState>? _authSubscription;
  StreamSubscription<void>? _enlaceSubscription;
  bool _guideCheckStarted = false;

  @override
  void initState() {
    super.initState();
    // gasocan://app/electricos: vuelve a la pestaña de gasolineras.
    _enlaceSubscription = Enlaces.electricos.listen((_) {
      if (mounted) setState(() => _currentIndex = 0);
    });
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _showGuideOnFirstLaunch(),
    );
    // Escuchar cambios en el estado de autenticación. Solo reseteamos a la
    // pestaña de inicio cuando el usuario CIERRA sesión, no en cada evento.
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) {
      if (!mounted) return;
      setState(() {
        final userId = data.session?.user.id;
        if (_userId != userId) {
          _userId = userId;
          _favorites = FavoriteRepository();
        }
        if (data.event == AuthChangeEvent.signedOut) _currentIndex = 0;
      });
    });
  }

  Future<void> _showGuideOnFirstLaunch() async {
    if (_guideCheckStarted || !mounted) return;
    _guideCheckStarted = true;
    final preferences = await SharedPreferences.getInstance();
    if (!mounted || preferences.getBool(GuidePage.seenKey) == true) return;
    await context.push('/guide?first=1');
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _enlaceSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final isLoggedIn = user != null;
    final pages = <Widget>[
      GasStationListPage(key: ValueKey('stations-${user?.id}')),
      FavoritesPage(
        key: ValueKey('favorites-${user?.id}'),
        repository: _favorites,
      ),
      ProfilePage(key: ValueKey('profile-${user?.id}')),
    ];

    // Los títulos van traducidos; en iOS la barra nativa los recibe de aquí.
    final items = <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: const Icon(Icons.local_gas_station),
        label: context.l10n.navStations,
      ),
      if (isLoggedIn)
        BottomNavigationBarItem(
          icon: const Icon(Icons.star),
          label: context.l10n.navFavorites,
        ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.person),
        label: context.l10n.navProfile,
      ),
    ];

    // Índice real dentro de pages. Si no está logueado, la barra oculta
    // favoritos, así que el índice 1 de la barra corresponde al índice 2
    // de pages (perfil).
    final pageIndex = isLoggedIn
        ? (_currentIndex >= pages.length ? 0 : _currentIndex)
        : (_currentIndex == 2 ? 2 : 0);

    // Índice que ve la BottomNavigationBar (sin hueco de favoritos oculto).
    final bottomNavIndex = isLoggedIn
        ? (pageIndex >= items.length ? 0 : pageIndex)
        : (pageIndex == 2 ? 1 : 0);

    final ios = !kIsWeb && Theme.of(context).platform == TargetPlatform.iOS;
    // Medidas de la barra de pestañas de Apple: en iOS 26 cápsula flotante
    // de 62 pt a 21 pt de los lados y del borde de abajo; antes, la clásica
    // de 49 pt de lado a lado más el hueco del indicador de inicio.
    final floating = ios && _iosMajor() >= 26;
    final safe = MediaQuery.paddingOf(context);
    final safeBottom = safe.bottom;
    final lateral = safe.left < safe.right ? safe.left : safe.right;
    // iPhone Duo cerrado: la cámara y la barra de estado van en una franja
    // vertical a un lado y el dock del sistema va en esa franja, abajo. La
    // barra de pestañas hace lo mismo: cápsula vertical solo con iconos.
    final size = MediaQuery.sizeOf(context);
    final franjaDerecha = safe.right >= 60;
    final franja = franjaDerecha ? safe.right : safe.left;
    final enFranja = floating && franja >= 60 && size.height > size.width;
    final abajo = safeBottom > 0 ? (safeBottom - 13).clamp(8.0, 40.0) : 21.0;
    final textExtra = (MediaQuery.textScalerOf(context).scale(10) - 10).clamp(
      0.0,
      24.0,
    );
    void select(int index) {
      setState(() => _currentIndex = isLoggedIn ? index : (index == 1 ? 2 : 0));
    }

    return Scaffold(
      extendBody: ios,
      // La lista se aparta de la cámara (iPhone Duo cerrado); la barra de
      // abajo no, para quedar centrada en la pantalla entera.
      body: Stack(
        children: [
          MargenLateral(
            child: IndexedStack(index: pageIndex, children: pages),
          ),
          if (enFranja)
            Positioned(
              bottom: abajo,
              right: franjaDerecha ? (franja - 62) / 2 : null,
              left: franjaDerecha ? null : (franja - 62) / 2,
              width: 62,
              height: items.length * 58.0 + 8,
              child: IosGlassNavigationBar(
                labels: items.map((item) => item.label!).toList(),
                symbols: [
                  'fuelpump',
                  if (isLoggedIn) 'star',
                  'person.crop.circle',
                ],
                selectedIndex: bottomNavIndex,
                vertical: true,
                onSelected: select,
              ),
            ),
        ],
      ),
      bottomNavigationBar: enFranja
          ? null
          : ios
          ? Padding(
              padding: floating
                  ? EdgeInsets.fromLTRB(
                      // Igual a los dos lados: centrada en la pantalla
                      // aunque solo haya margen en uno (iPhone Duo cerrado).
                      21 + lateral,
                      0,
                      21 + lateral,
                      safeBottom > 0 ? (safeBottom - 13).clamp(8.0, 40.0) : 8,
                    )
                  : EdgeInsets.zero,
              child: SizedBox(
                height: floating ? 62 + textExtra : 49 + textExtra + safeBottom,
                child: IosGlassNavigationBar(
                  labels: items.map((item) => item.label!).toList(),
                  symbols: [
                    'fuelpump',
                    if (isLoggedIn) 'star',
                    'person.crop.circle',
                  ],
                  selectedIndex: bottomNavIndex,
                  floating: floating,
                  bottomInset: floating ? 0 : safeBottom,
                  onSelected: select,
                ),
              ),
            )
          : NavigationBar(
              selectedIndex: bottomNavIndex,
              onDestinationSelected: select,
              destinations: items
                  .map(
                    (item) => NavigationDestination(
                      icon: item.icon,
                      label: item.label!,
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

/// Versión principal de iOS («Version 26.1 (Build …)» → 26).
int _iosMajor() {
  final match = RegExp(r'(\d+)').firstMatch(Platform.operatingSystemVersion);
  return int.tryParse(match?.group(1) ?? '') ?? 0;
}
