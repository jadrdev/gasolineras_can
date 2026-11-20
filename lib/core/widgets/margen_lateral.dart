import 'package:material_ui/material_ui.dart';

/// Ancho máximo de listas, fichas y formularios. En pantallas más anchas
/// (iPhone Duo abierto, iPhone en horizontal) van en una columna centrada:
/// tarjetas de 900 puntos se leen mal.
const anchoMaximoContenido = 640.0;

/// Aparta el contenido de la zona segura de los lados y lo limita a
/// [anchoMaximo] (null = todo el ancho, para los mapas). Con el iPhone Duo
/// cerrado la cámara va en una franja a la derecha; en un iPhone en vertical
/// no hay margen lateral y no cambia nada. Arriba y abajo lo resuelve cada
/// pantalla (AppBar y barra de pestañas).
class MargenLateral extends StatelessWidget {
  const MargenLateral({
    super.key,
    required this.child,
    this.anchoMaximo = anchoMaximoContenido,
  });

  final Widget child;
  final double? anchoMaximo;

  @override
  Widget build(BuildContext context) {
    final safe = MediaQuery.paddingOf(context);
    final ancho = MediaQuery.sizeOf(context).width - safe.left - safe.right;
    final limitar = anchoMaximo != null && ancho > anchoMaximo!;
    if (safe.left == 0 && safe.right == 0 && !limitar) return child;
    Widget contenido = SafeArea(top: false, bottom: false, child: child);
    if (limitar) {
      contenido = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: anchoMaximo!),
          child: contenido,
        ),
      );
    }
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: contenido,
    );
  }
}

/// Nombre de ruta de las pantallas que van a todo el ancho (los mapas):
/// `RouteSettings(name: rutaATodoElAncho)` al abrirlas.
const rutaATodoElAncho = 'todo-el-ancho';

/// Transición de página normal con [MargenLateral] alrededor de cada pantalla.
/// La principal ('/home') se lo pone ella misma solo a la lista, para que la
/// barra de pestañas quede donde le toca (abajo o en la franja de la cámara).
/// Los mapas ([rutaATodoElAncho]) solo se apartan de la zona segura.
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
    switch (route.settings.name) {
      '/home' => child,
      rutaATodoElAncho => MargenLateral(anchoMaximo: null, child: child),
      _ => MargenLateral(child: child),
    },
  );
}
