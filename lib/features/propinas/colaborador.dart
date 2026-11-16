import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Iconos de la app que se desbloquean con cualquier propina.
enum IconoApp {
  original,
  noche,
  naranja,
  cafe;

  /// Vista previa para el selector.
  String get asset => 'assets/icon/alternativos/$name.png';

  /// Nombre del icono alternativo en iOS (conjunto del asset catalog).
  String? get nombreIos => switch (this) {
    IconoApp.original => null,
    IconoApp.noche => 'AppIcon-Noche',
    IconoApp.naranja => 'AppIcon-Naranja',
    IconoApp.cafe => 'AppIcon-Cafe',
  };
}

/// Quien ha dado alguna propina es «colaborador»: lleva la insignia en el
/// perfil y puede cambiar el icono de la app. Es un agradecimiento simbólico.
///
/// Se guarda en el móvil y, si hay sesión, también en `users.colaborador`
/// (supabase/colaborador.sql), para conservarlo al cambiar de móvil.
class Colaborador {
  Colaborador._();

  static const _clave = 'colaborador';
  static const _canal = MethodChannel('gasocan/icono');

  /// Si este usuario es colaborador; la interfaz se redibuja al cambiar.
  static final activo = ValueNotifier<bool>(false);

  static SupabaseClient get _supabase => Supabase.instance.client;

  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      activo.value = prefs.getBool(_clave) ?? false;
    } catch (e) {
      debugPrint('⚠️ Colaborador: no se pudo leer: $e');
    }
    unawaited(_sincronizar());
    _supabase.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn) unawaited(_sincronizar());
    });
  }

  /// Se llama al recibir una propina.
  static Future<void> marcar() async {
    activo.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_clave, true);
    } catch (e) {
      debugPrint('⚠️ Colaborador: no se pudo guardar: $e');
    }
    await _guardarEnCuenta();
  }

  /// Con sesión: si el móvil ya lo sabía lo sube a la cuenta, y si la cuenta
  /// lo sabía (otro móvil) lo baja a este.
  static Future<void> _sincronizar() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    if (activo.value) {
      await _guardarEnCuenta();
      return;
    }
    try {
      final fila = await _supabase
          .from('users')
          .select('colaborador')
          .eq('id', user.id)
          .maybeSingle();
      if (fila?['colaborador'] == true) {
        activo.value = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_clave, true);
      }
    } catch (e) {
      debugPrint('⚠️ Colaborador: no se pudo leer de la cuenta: $e');
    }
  }

  static Future<void> _guardarEnCuenta() async {
    if (_supabase.auth.currentUser == null) return;
    try {
      await _supabase.rpc('marcar_colaborador');
    } catch (e) {
      debugPrint('⚠️ Colaborador: no se pudo guardar en la cuenta: $e');
    }
  }

  /// Icono que tiene ahora la app.
  static Future<IconoApp> iconoActual() async {
    try {
      final nombre = await _canal.invokeMethod<String>('actual');
      return IconoApp.values.firstWhere(
        (i) => defaultTargetPlatform == TargetPlatform.iOS
            ? i.nombreIos == nombre
            : (nombre ?? 'original') == i.name,
        orElse: () => IconoApp.original,
      );
    } catch (_) {
      return IconoApp.original;
    }
  }

  /// Cambia el icono de la app. Devuelve false si el sistema no lo permite.
  static Future<bool> cambiarIcono(IconoApp icono) async {
    try {
      final ok = await _canal.invokeMethod<bool>(
        'cambiar',
        defaultTargetPlatform == TargetPlatform.iOS
            ? icono.nombreIos
            : icono.name,
      );
      return ok ?? false;
    } catch (e) {
      debugPrint('⚠️ No se pudo cambiar el icono: $e');
      return false;
    }
  }
}
