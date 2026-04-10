import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_providers.dart';

final FlutterLocalNotificationsPlugin _localNotif =
    FlutterLocalNotificationsPlugin();

class NotificationService {
  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);
    await _localNotif.initialize(initSettings);

    await _localNotif
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          'washgo_notifications',
          'WashGo Notifications',
          description: 'Order status updates',
          importance: Importance.high,
        ));
  }

  static Future<void> showLocal(String title, String body) async {
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
    if (Platform.isAndroid) {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();
      final token = await messaging.getToken();
      if (token != null) {
        final session = await ref.watch(authStateProvider.future);
        if (session != null) {
          final sb = ref.read(supabaseProvider);
          await sb.from('push_tokens').upsert({
            'user_id': session.user.id,
            'token': token,
            'platform': 'android',
          }, onConflict: 'user_id,token');
        }
      }
      return token;
    }
  } catch (_) {}
  return null;
});
