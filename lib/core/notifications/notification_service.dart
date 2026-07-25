import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<bool> init() async {
    // 🔹 Configuración Android
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    // 🔹 Configuración iOS
    const iOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // 🔹 Configuración general
    const settings = InitializationSettings(android: android, iOS: iOS);

    final initialized = await _notifications.initialize(settings);

    // En iOS pedimos permisos de forma explícita. En Android 13+ también se
    // solicita automáticamente por el plugin al mostrar la primera notificación
    // si se configura el canal con importancia alta.
    return initialized ?? false;
  }

  /// Solicita permisos de notificación de forma explícita.
  /// Devuelve `true` si el usuario concedió al menos permiso de alerta.
  static Future<bool> requestPermissions() async {
    final iosImpl = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosImpl != null) {
      final granted = await iosImpl.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    final macOsImpl = _notifications.resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>();
    if (macOsImpl != null) {
      final granted = await macOsImpl.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    // En Android asumimos true; el canal se configura con alta importancia.
    return true;
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    debugPrint('🔔 showNotification: title="$title" body="$body"');

    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'General',
      channelDescription: 'Notificaciones generales',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.active,
    );

    const platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    try {
      await _notifications.show(
        id,
        title,
        body,
        platformDetails,
      );
      debugPrint('✅ Notificación mostrada correctamente (id=$id)');
    } catch (e, stack) {
      debugPrint('❌ Error mostrando notificación: $e');
      debugPrint(stack.toString());
    }
  }
}
