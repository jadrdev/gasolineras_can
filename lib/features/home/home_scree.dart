import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:gasolineras_can/features/auth/profile_page.dart';
import 'package:gasolineras_can/features/favoritos/favoritos_page.dart';
import 'package:gasolineras_can/features/gasolineras/presentacion/gas_station_list_page.dart';
import 'package:gasolineras_can/features/favoritos/data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:ui';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final FavoriteRepository _favoriteRepository = FavoriteRepository();
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    // Escuchar cambios en el estado de autenticación
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      // Cuando cambia el estado de autenticación, reconstruir y resetear el índice
      setState(() {
        _currentIndex = 0;
      });
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
    final bool isIOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

    // Construir páginas según el estado de autenticación
    final pages = <Widget>[
      // Tab 0: Gasolineras (siempre visible)
      const GasStationListPage(),
      // Tab 1: Favoritos (solo si está logueado) o Perfil (si no está logueado)
      if (isLoggedIn) FavoritesPage(repository: _favoriteRepository),
      // Tab 2 (o Tab 1 si no está logueado): Perfil (siempre visible)
      const ProfilePage(),
    ];

    Widget buildIosTabBar() {
      final items = <CNTabBarItem>[
        const CNTabBarItem(label: 'Gasolineras', icon: CNSymbol('house.fill')),
        if (isLoggedIn)
          const CNTabBarItem(label: 'Favoritos', icon: CNSymbol('star.fill')),
        const CNTabBarItem(label: 'Perfil', icon: CNSymbol('person.crop.circle')),
      ];

      return Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Container(
            color: Colors.white.withOpacity(0.12),
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: CNTabBar(
              items: items,
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
            ),
          ),
        ),
      );
    }

    Widget buildMaterialTabBar() {
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

      return BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        items: items,
      );
    }

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      extendBody: true,
      bottomNavigationBar: isIOS ? buildIosTabBar() : buildMaterialTabBar(),
    );
  }
}
