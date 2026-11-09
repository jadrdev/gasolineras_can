import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const _priceAlertsChannel = AndroidNotificationChannel(
    'price_alerts',
    'Bajadas de precio',
    description: 'Avisos cuando baja el precio en tus gasolineras favoritas',
    importance: Importance.high,
  );

  static Future<bool> init() async {
    // 🔹 Configuración Android
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    // 🔹 Configuración iOS
    const iOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    // 🔹 Configuración general
    const settings = InitializationSettings(android: android, iOS: iOS);

    final initialized = await _notifications.initialize(settings);

    // Canal de las alertas de precio; la Edge Function price-alerts manda las
    // push a este mismo canal (android.notification.channel_id).
    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_priceAlertsChannel);

    return initialized ?? false;
  }

  /// Solicita permisos de notificación de forma explícita.
  /// Devuelve `true` si el usuario concedió al menos permiso de alerta.
  static Future<bool> requestPermissions() async {
    final iosImpl = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (iosImpl != null) {
      final granted = await iosImpl.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    final macOsImpl = _notifications
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();
    if (macOsImpl != null) {
      final granted = await macOsImpl.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    final androidImpl = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidImpl != null) {
      return await androidImpl.requestNotificationsPermission() ?? false;
    }
    return false;
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    debugPrint('🔔 showNotification: title="$title" body="$body"');

    final androidDetails = AndroidNotificationDetails(
      _priceAlertsChannel.id,
      _priceAlertsChannel.name,
      channelDescription: _priceAlertsChannel.description,
      importance: Importance.high,
      priority: Priority.high,
    );

    const iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.active,
    );

    final platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    try {
      await _notifications.show(id, title, body, platformDetails);
      debugPrint('✅ Notificación mostrada correctamente (id=$id)');
    } catch (e, stack) {
      debugPrint('❌ Error mostrando notificación: $e');
      debugPrint(stack.toString());
    }
  }
}
