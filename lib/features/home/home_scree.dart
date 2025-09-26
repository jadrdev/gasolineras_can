import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:gasolineras_can/features/auth/profile_page.dart';
import 'package:gasolineras_can/features/favoritos/favoritos_page.dart';
import 'package:gasolineras_can/features/gasolineras/presentacion/gas_station_list_page.dart';
import 'package:gasolineras_can/features/favoritos/data.dart';
import 'dart:ui';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final FavoriteRepository _favoriteRepository = FavoriteRepository();

  // _pages removed; pages are constructed in build

  @override
  void initState() {
    super.initState();
    // no añadir aquí GasStationListPage directamente porque necesita parámetros en tu implementación,
    // vamos a construir la lista en build para poder pasar repository si hace falta.
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      // Tab 0: Gasolineras (usa tu GasStationListPage tal cual)
      const GasStationListPage(),
      // Tab 1: Favoritos (implementamos una página sencilla)
      FavoritesPage(repository: _favoriteRepository),
      // Tab 2: Perfil
      ProfilePage(),
    ];

    final bool isIOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

    Widget buildIosTabBar() {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Container(
            color: Colors.white.withOpacity(0.12),
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: CNTabBar(
              items: const [
                CNTabBarItem(label: 'Gasolineras', icon: CNSymbol('house.fill')),
                CNTabBarItem(label: 'Favoritos', icon: CNSymbol('star.fill')),
                CNTabBarItem(label: 'Perfil', icon: CNSymbol('person.crop.circle')),
              ],
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
            ),
          ),
        ),
      );
    }

    Widget buildMaterialTabBar() {
      return BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_gas_station),
            label: 'Gasolineras',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Favoritos'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      );
    }

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      extendBody: true,
      bottomNavigationBar: isIOS ? buildIosTabBar() : buildMaterialTabBar(),
    );
  }
}
