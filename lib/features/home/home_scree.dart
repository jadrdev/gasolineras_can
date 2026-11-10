import 'package:flutter/foundation.dart';
import '../../core/widgets/ios_glass_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:gasolineras_can/features/auth/profile_page.dart';
import 'package:gasolineras_can/features/favoritos/favoritos_page.dart';
import 'package:gasolineras_can/features/gasolineras/presentacion/gas_station_list_page.dart';
import 'package:gasolineras_can/features/favoritos/data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:gasolineras_can/features/guide/guide_page.dart';
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
  bool _guideCheckStarted = false;

  @override
  void initState() {
    super.initState();
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

    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.local_gas_station),
        label: 'Gasolineras',
      ),
      if (isLoggedIn)
        const BottomNavigationBarItem(
          icon: Icon(Icons.star),
          label: 'Favoritos',
        ),
      const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
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
    void select(int index) {
      setState(() => _currentIndex = isLoggedIn ? index : (index == 1 ? 2 : 0));
    }

    return Scaffold(
      extendBody: ios,
      body: IndexedStack(index: pageIndex, children: pages),
      bottomNavigationBar: ios
          ? SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(40, 0, 40, 8),
              child: SizedBox(
                height:
                    52 +
                    (MediaQuery.textScalerOf(context).scale(12) - 12).clamp(
                      0,
                      32,
                    ),
                child: IosGlassNavigationBar(
                  labels: items.map((item) => item.label!).toList(),
                  symbols: [
                    'fuelpump',
                    if (isLoggedIn) 'star',
                    'person.crop.circle',
                  ],
                  selectedIndex: bottomNavIndex,
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
