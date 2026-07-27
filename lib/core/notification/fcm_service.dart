import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../../../app/router/app_router.dart';
import '../../../app/router/route_names.dart';
import '../logger/app_logger.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';

/// Manages Firebase Cloud Messaging registration and foreground notifications.
@lazySingleton
class FcmService {
  FcmService(this._messaging, this._dioClient);

  final FirebaseMessaging _messaging;
  final DioClient _dioClient;

  Future<void> init() async {
    // Request permission (iOS)
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await _messaging.getToken();
    AppLogger.info('FCM Token: $token');
    if (token != null) {
      _syncToken(token);
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Handle notification tap when app was in background
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // Token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      AppLogger.info('FCM Token refreshed: $newToken');
      _syncToken(newToken);
    });
  }

  Future<void> _syncToken(String token) async {
    try {
      await _dioClient.dio.post(
        ApiEndpoints.deviceToken,
        data: {'fcmToken': token},
      );
    } catch (e) {
      AppLogger.error('Failed to sync FCM token: $e');
    }
  }

  Future<String?> getToken() => _messaging.getToken();

  void _onForegroundMessage(RemoteMessage message) {
    AppLogger.info('Foreground FCM: ${message.notification?.title}');
    final context = AppRouter.router.routerDelegate.navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message.notification?.title ?? 'New notification'),
          action: SnackBarAction(
            label: 'View',
            onPressed: () => _handleDeepLink(message.data),
          ),
        ),
      );
    }
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    AppLogger.info('Notification opened: ${message.data}');
    _handleDeepLink(message.data);
  }

  void _handleDeepLink(Map<String, dynamic> data) {
    AppRouter.router.push(RouteNames.notifications);
  }
}
