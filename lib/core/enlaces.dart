import 'dart:async';

/// Enlaces que abren la app en un sitio concreto.
///
/// `gasocan://app/electricos` abre la lista con «⚡ Eléctrico» elegido. Lo usa
/// el evento dentro de la app del App Store («Puntos de recarga en Canarias»),
/// que exige un enlace profundo. Flutter recibe la ruta `/electricos` y la
/// pasa al router (FlutterDeepLinkingEnabled en iOS y flutter_deeplinking_enabled
/// en Android); el router llama a [pedirElectricos] y manda a `/home`.
class Enlaces {
  Enlaces._();

  static final _electricos = StreamController<void>.broadcast();
  static bool _pendiente = false;

  /// Avisa a la pantalla principal y a la lista de que hay que mostrar
  /// los puntos de recarga.
  static Stream<void> get electricos => _electricos.stream;

  static void pedirElectricos() {
    _pendiente = true;
    _electricos.add(null);
  }

  /// Para la lista recién creada (arranque en frío desde el enlace): devuelve
  /// true una sola vez si había una petición sin atender.
  static bool consumirElectricos() {
    final pendiente = _pendiente;
    _pendiente = false;
    return pendiente;
  }
}
