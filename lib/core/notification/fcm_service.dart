import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:injectable/injectable.dart';

import '../logger/app_logger.dart';

/// Manages Firebase Cloud Messaging registration and foreground notifications.
@lazySingleton
class FcmService {
  FcmService(this._messaging);

  final FirebaseMessaging _messaging;

  Future<void> init() async {
    // Request permission (iOS)
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await _messaging.getToken();
    AppLogger.info('FCM Token: $token');

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Handle notification tap when app was in background
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // Token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      AppLogger.info('FCM Token refreshed: $newToken');
      // TODO: sync new token to backend
    });
  }

  Future<String?> getToken() => _messaging.getToken();

  void _onForegroundMessage(RemoteMessage message) {
    AppLogger.info('Foreground FCM: ${message.notification?.title}');
    // TODO: dispatch to NotificationCubit for in-app banner
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    AppLogger.info('Notification opened: ${message.data}');
    // TODO: navigate to relevant screen via deep link
  }
}
