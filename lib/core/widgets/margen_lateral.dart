import 'package:material_ui/material_ui.dart';

/// Aparta el contenido de la zona segura de los lados. Con el iPhone Duo
/// cerrado la cámara y la barra de estado van en una franja a la derecha; en
/// los demás iPhone en vertical ese margen es 0 y no cambia nada. Arriba y
/// abajo lo resuelve cada pantalla (AppBar y barra de pestañas).
class MargenLateral extends StatelessWidget {
  const MargenLateral({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final safe = MediaQuery.paddingOf(context);
    if (safe.left == 0 && safe.right == 0) return child;
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(top: false, bottom: false, child: child),
    );
  }
}

/// Transición de página normal con [MargenLateral] alrededor de cada pantalla.
/// La principal ('/home') se lo pone ella misma solo a la lista, para que la
/// barra de pestañas quede centrada en la pantalla entera: la franja de la
/// cámara solo ocupa la parte de arriba.
class TransicionConMargenLateral extends PageTransitionsBuilder {
  const TransicionConMargenLateral(this.base);

  final PageTransitionsBuilder base;

  /// Las transiciones por defecto de cada plataforma, con el margen.
  static PageTransitionsTheme get tema => PageTransitionsTheme(
    builders: {
      for (final e in const PageTransitionsTheme().builders.entries)
        e.key: TransicionConMargenLateral(e.value),
    },
  );

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => base.buildTransitions(
    route,
    context,
    animation,
    secondaryAnimation,
    route.settings.name == '/home' ? child : MargenLateral(child: child),
  );
}
