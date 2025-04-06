import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationManager {
  NotificationManager._();

  static NotificationManager get instance => _instance;
  static final NotificationManager _instance = NotificationManager._();

  /// 변경하면 AndroidManifest.xml에 정의되어 있는
  /// com.google.firebase.messaging.default_notification_channel_id 값도 변경되어야 함
  static const String androidNotificationChannelId = 'default';

  static const String androidNotificationChannelName = '기본';

  final AndroidFlutterLocalNotificationsPlugin _localNotificationsPlugin =
      AndroidFlutterLocalNotificationsPlugin();

  /// [Navigator] 하위 위젯의 [context]가 필요함.
  Future<void> initialize(BuildContext context) async {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (context.mounted) {
        _handleNotificationAction(message.data, context);
      }
    });

    await _initializeForegroundNotification(context);

    if (context.mounted) {
      await _handleInitialNotification(context);
    }
  }

  Future<void> _initializeForegroundNotification(BuildContext context) async {
    if (Platform.isIOS) {
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    if (Platform.isAndroid) {
      FirebaseMessaging.onMessage.listen(_showLocalNotification);

      await _localNotificationsPlugin.initialize(
        AndroidInitializationSettings('@mipmap/launcher_icon'),
        onDidReceiveNotificationResponse: (details) {
          _onLocalNotificationResponse(details, context);
        },
      );
      await _localNotificationsPlugin.createNotificationChannel(
        AndroidNotificationChannel(androidNotificationChannelId, androidNotificationChannelName),
      );
    }
  }

  void _showLocalNotification(RemoteMessage message) {
    if (!Platform.isAndroid) return;

    final notification = message.notification;
    if (notification == null) return;

    _localNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      notificationDetails: AndroidNotificationDetails(
        androidNotificationChannelId,
        androidNotificationChannelName,
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _onLocalNotificationResponse(NotificationResponse response, BuildContext context) {
    final payload = response.payload;
    if (payload == null) return;

    final data = jsonDecode(payload);
    _handleNotificationAction(data, context);
  }

  Future<void> _handleInitialNotification(BuildContext context) async {
    final RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null && context.mounted) {
      _handleNotificationAction(initialMessage.data, context);
    }

    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await _localNotificationsPlugin.getNotificationAppLaunchDetails();
    final notificationResponse = notificationAppLaunchDetails?.notificationResponse;
    if (notificationAppLaunchDetails?.didNotificationLaunchApp == true &&
        notificationResponse != null &&
        context.mounted) {
      _onLocalNotificationResponse(notificationResponse, context);
    }
  }

  void _handleNotificationAction(Map<String, dynamic> data, BuildContext context) {
    final routeName = data['routeName'];
    if (routeName != null) {
      Navigator.pushNamed(context, routeName);
    }

    final url = data['url'];
    if (url != null) {
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
}
