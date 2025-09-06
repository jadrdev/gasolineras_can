import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // 🔹 Configuración Android
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    // 🔹 Configuración iOS
    const iOS = DarwinInitializationSettings();

    // 🔹 Configuración general
    const settings = InitializationSettings(android: android, iOS: iOS);

    await _notifications.initialize(settings);
  }

  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'General',
      channelDescription: 'Notificaciones generales',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iOSDetails = DarwinNotificationDetails();

    const platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _notifications.show(
      0, // ID de la notificación
      title,
      body,
      platformDetails,
    );
  }
}
