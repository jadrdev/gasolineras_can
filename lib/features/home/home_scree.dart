import 'package:flutter/material.dart';
import 'package:gasolineras_can/features/auth/profile_page.dart';
import 'package:gasolineras_can/features/favoritos/favoritos_page.dart';
import 'package:gasolineras_can/features/gasolineras/presentacion/gas_station_list_page.dart';
import 'package:gasolineras_can/features/favoritos/data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

// NOTA: el `cupertino_native` original se ha quitado. Daba problemas de FFI
// con iOS 26+. BottomNavigationBar de Material cubre el mismo caso de uso
// en ambas plataformas. Si más adelante quieres look-and-feel nativo de
// iOS, podemos volver a meterlo cuando esté estable.

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final FavoriteRepository _favoriteRepository = FavoriteRepository();
  StreamSubscription<AuthState>? _authSubscription;

  // Páginas estables para que IndexedStack conserve su estado al cambiar de tab.
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const GasStationListPage(key: PageStorageKey('gas_stations')),
      FavoritesPage(
        key: const PageStorageKey('favorites'),
        repository: _favoriteRepository,
      ),
      const ProfilePage(key: PageStorageKey('profile')),
    ];

    // Escuchar cambios en el estado de autenticación. Solo reseteamos a la
    // pestaña de inicio cuando el usuario CIERRA sesión, no en cada evento.
    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (!mounted) return;
      if (data.event == AuthChangeEvent.signedOut) {
        setState(() {
          _currentIndex = 0;
        });
      }
    });
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

    // Si no está logueado, ocultamos la pestaña de favoritos pero mantenemos
    // las páginas en el IndexedStack para no perder el estado al volver.
    final safeIndex = isLoggedIn
        ? (_currentIndex >= _pages.length ? 0 : _currentIndex)
        : (_currentIndex == 1 ? 0 : _currentIndex);

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
      const BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Perfil',
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: safeIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: safeIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        items: items,
      ),
    );
  }
}
