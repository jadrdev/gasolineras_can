import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cupertino_native/cupertino_native.dart';

class GlassNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const GlassNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          color: Colors.white.withOpacity(0.12),
          child: CNTabBar(
            items: const [
              CNTabBarItem(label: 'Gasolineras', icon: CNSymbol('house.fill')),
              CNTabBarItem(label: 'Favoritos', icon: CNSymbol('star.fill')),
              CNTabBarItem(label: 'Perfil', icon: CNSymbol('person.crop.circle')),
            ],
            currentIndex: currentIndex,
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}
