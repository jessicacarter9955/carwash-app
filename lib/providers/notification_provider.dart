import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_providers.dart';

final FlutterLocalNotificationsPlugin _localNotif =
    FlutterLocalNotificationsPlugin();

class NotificationService {
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotif.initialize(initSettings);

    // Create Android notification channel
    await _localNotif
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            'washgo_notifications',
            'WashGo Notifications',
            description: 'Order status updates and location changes',
            importance: Importance.high,
          ),
        );
  }

  /// Request permission for notifications (Android 13+ and iOS)
  static Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final plugin = _localNotif
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final granted = await plugin?.requestNotificationsPermission();
      return granted ?? false;
    } else if (Platform.isIOS) {
      final plugin = _localNotif
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final granted = await plugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    return false;
  }

  static Future<void> showLocal(String title, String body) async {
    await init();
    await _localNotif.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'washgo_notifications',
          'WashGo Notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }
}

final notificationProvider = Provider<void>((ref) {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final n = message.notification;
    if (n != null) {
      NotificationService.showLocal(n.title ?? 'WashGo', n.body ?? '');
    }
  });
});

final fcmTokenProvider = FutureProvider<String?>((ref) async {
  try {
    final messaging = FirebaseMessaging.instance;

    // Request FCM permission (covers iOS + Android 13+)
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return null;
    }

    final token = await messaging.getToken();
    if (token != null) {
      final session = await ref.watch(authStateProvider.future);
      if (session != null) {
        final sb = ref.read(supabaseProvider);
        await sb.from('push_tokens').upsert({
          'user_id': session.user.id,
          'token': token,
          'platform': Platform.isIOS ? 'ios' : 'android',
        }, onConflict: 'user_id,token');
      }
    }
    return token;
  } catch (_) {}
  return null;
});
