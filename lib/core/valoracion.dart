import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pide la valoración de la tienda (la ventanita oficial de Apple y Google)
/// cuando la app ya le ha sido útil a alguien, nunca al primer uso.
///
/// Cuenta como uso útil abrir la ruta a una gasolinera o a un cargador.
/// La petición no sale al pulsar «Cómo llegar» (la persona se va al mapa),
/// sino al volver a la app después.
///
/// Se pide si:
///  - han pasado al menos [_diasMinimos] días desde el primer arranque,
///  - y se ha abierto la ruta [_rutasMinimas] veces o se ha usado la app
///    [_diasDeUsoMinimos] días distintos,
///  - y no se ha pedido en los últimos [_diasEntrePeticiones] días.
///
/// Además las tiendas limitan cuántas veces se muestra (Apple, 3 al año), así
/// que puede no salir aunque se cumpla todo: es lo esperado.
class Valoracion {
  Valoracion._();

  static const _diasMinimos = 3;
  static const _rutasMinimas = 3;
  static const _diasDeUsoMinimos = 5;
  static const _diasEntrePeticiones = 120;

  static const _kPrimerUso = 'valoracion.primer_uso';
  static const _kRutas = 'valoracion.rutas';
  static const _kDiasDeUso = 'valoracion.dias_de_uso';
  static const _kUltimoDia = 'valoracion.ultimo_dia';
  static const _kUltimaPeticion = 'valoracion.ultima_peticion';

  static AppLifecycleListener? _ciclo;
  static bool _rutaReciente = false;

  /// En el arranque: apunta el día de uso y escucha la vuelta a la app.
  static Future<void> init() async {
    _ciclo ??= AppLifecycleListener(onResume: _alVolver);
    final prefs = await SharedPreferences.getInstance();
    final hoy = _hoy();
    prefs.getString(_kPrimerUso) ?? await prefs.setString(_kPrimerUso, hoy);
    if (prefs.getString(_kUltimoDia) != hoy) {
      await prefs.setString(_kUltimoDia, hoy);
      await prefs.setInt(_kDiasDeUso, (prefs.getInt(_kDiasDeUso) ?? 0) + 1);
    }
    // Con la app ya abierta un rato, por si se cumple por días de uso.
    Timer(const Duration(seconds: 20), _quizasPedir);
  }

  /// Se ha abierto la ruta a una gasolinera o a un cargador.
  static Future<void> rutaAbierta() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kRutas, (prefs.getInt(_kRutas) ?? 0) + 1);
    _rutaReciente = true;
  }

  static void _alVolver() {
    if (!_rutaReciente) return;
    _rutaReciente = false;
    // Un momento para que la app termine de volver a primer plano.
    Timer(const Duration(seconds: 2), _quizasPedir);
  }

  static Future<void> _quizasPedir() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ahora = DateTime.now();
      final primerUso = DateTime.tryParse(prefs.getString(_kPrimerUso) ?? '');
      if (primerUso == null ||
          ahora.difference(primerUso).inDays < _diasMinimos) {
        return;
      }
      final usoSuficiente =
          (prefs.getInt(_kRutas) ?? 0) >= _rutasMinimas ||
          (prefs.getInt(_kDiasDeUso) ?? 0) >= _diasDeUsoMinimos;
      if (!usoSuficiente) return;
      final ultima = DateTime.tryParse(prefs.getString(_kUltimaPeticion) ?? '');
      if (ultima != null &&
          ahora.difference(ultima).inDays < _diasEntrePeticiones) {
        return;
      }
      final review = InAppReview.instance;
      if (!await review.isAvailable()) return;
      await prefs.setString(_kUltimaPeticion, ahora.toIso8601String());
      await review.requestReview();
    } catch (e) {
      debugPrint('Valoración: $e');
    }
  }

  static String _hoy() {
    final d = DateTime.now();
    return DateTime(d.year, d.month, d.day).toIso8601String();
  }
}
