import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../l10n/l10n.dart';
import 'notification_service.dart';

/// Notificaciones push de bajada de precio.
///
/// La app solo registra el token FCM del dispositivo en Supabase
/// (`register_push_token`); quien decide cuándo avisar es la Edge Function
/// `price-alerts`, que corre cada hora en el servidor aunque la app esté
/// cerrada.
class PushService {
  PushService._();

  static bool _initialized = false;

  static FirebaseMessaging get _messaging => FirebaseMessaging.instance;
  static SupabaseClient get _supabase => Supabase.instance.client;

  /// Se llama una vez al arrancar, después de `Firebase.initializeApp`.
  /// No pide permiso: eso se hace al guardar el primer favorito.
  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // iOS: mostrar la notificación también con la app abierta.
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Android no pinta las push con la app abierta: la mostramos nosotros.
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null ||
          defaultTargetPlatform != TargetPlatform.android) {
        return;
      }
      NotificationService.showNotification(
        id: int.tryParse(message.data['station_id'] ?? '') ?? 0,
        title: notification.title ?? '',
        body: notification.body ?? '',
      );
    });

    _messaging.onTokenRefresh.listen((_) => sync());

    _supabase.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn) sync();
    });

    unawaited(_syncWithRetries());
  }

  /// Al arrancar, iOS puede tardar en entregar el token de APNs. Si no está,
  /// se reintenta durante el primer minuto en vez de esperar a que el usuario
  /// toque una favorita (que es cuando antes se registraba).
  static Future<void> _syncWithRetries() async {
    const delays = [0, 5, 15, 30, 60];
    for (final seconds in delays) {
      if (seconds > 0) await Future<void>.delayed(Duration(seconds: seconds));
      if (await sync()) return;
    }
  }

  /// Pide permiso (solo la primera vez sale el diálogo del sistema) y
  /// registra el dispositivo. Devuelve si las notificaciones están permitidas.
  static Future<bool> requestPermissionAndSync() async {
    final settings = await _messaging.requestPermission();
    final allowed = _isAllowed(settings.authorizationStatus);
    if (allowed) await sync();
    return allowed;
  }

  /// Registra el token de este dispositivo para el usuario con sesión, si ya
  /// hay permiso. No pregunta nada al usuario.
  /// Devuelve `false` solo si había que registrar y no se pudo (sin token o
  /// error), para que [_syncWithRetries] lo vuelva a intentar.
  static Future<bool> sync() async {
    try {
      if (_supabase.auth.currentUser == null) return true;
      final settings = await _messaging.getNotificationSettings();
      if (!_isAllowed(settings.authorizationStatus)) return true;

      final token = await _token();
      if (token == null) {
        debugPrint('⏳ Push: todavía sin token de APNs');
        return false;
      }
      await _supabase.rpc(
        'register_push_token',
        params: {
          'p_token': token,
          'p_platform': _platform,
          // Idioma de la app: el servidor escribe los avisos en él.
          'p_locale': l10nSistema.localeName,
        },
      );
      debugPrint('🔔 Push: dispositivo registrado');
      return true;
    } catch (e) {
      debugPrint('⚠️ Push: no se pudo registrar el dispositivo: $e');
      return false;
    }
  }

  /// Quita este dispositivo de la cuenta actual. Llamar ANTES de cerrar
  /// sesión, mientras todavía hay usuario.
  static Future<void> unregister() async {
    try {
      final token = await _messaging.getToken();
      if (token != null && _supabase.auth.currentUser != null) {
        await _supabase.rpc(
          'unregister_push_token',
          params: {'p_token': token},
        );
      }
      await _messaging.deleteToken();
    } catch (e) {
      debugPrint('⚠️ Push: no se pudo quitar el dispositivo: $e');
    }
  }

  static Future<String?> _token() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // En iOS el token FCM necesita antes el de APNs, que solo llega si la
      // app se registra para notificaciones remotas. Eso lo hace
      // requestPermission; con el permiso ya concedido no muestra ningún
      // diálogo, solo vuelve a registrar.
      if (await _messaging.getAPNSToken() == null) {
        await _messaging.requestPermission();
      }
      for (var i = 0; i < 10; i++) {
        if (await _messaging.getAPNSToken() != null) break;
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
      if (await _messaging.getAPNSToken() == null) return null;
    }
    return _messaging.getToken();
  }

  static bool _isAllowed(AuthorizationStatus status) =>
      status == AuthorizationStatus.authorized ||
      status == AuthorizationStatus.provisional;

  static String get _platform =>
      defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';
}
