import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gasolineras_can/core/notifications/notification_service.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  test('iOS initialization never waits for notification permission', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    IOSFlutterLocalNotificationsPlugin.registerWith();
    const channel = MethodChannel('dexterous.com/flutter/local_notifications');
    final calls = <MethodCall>[];
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      call,
    ) async {
      calls.add(call);
      return true;
    });
    addTearDown(() {
      debugDefaultTargetPlatformOverride = null;
      binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
    });
    expect(await NotificationService.init(), isTrue);
    final arguments = calls.single.arguments as Map;
    expect(calls.single.method, 'initialize');
    expect(arguments['requestAlertPermission'], isFalse);
    expect(arguments['requestBadgePermission'], isFalse);
    expect(arguments['requestSoundPermission'], isFalse);
  });
}
