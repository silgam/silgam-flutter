import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationManager {
  const NotificationManager._();

  static NotificationManager get instance => _instance;
  static const NotificationManager _instance = NotificationManager._();

  void initializeFirebaseMessaging() {
    if (Platform.isIOS) {
      FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<void> initializeNotificationInteractions(BuildContext context) async {
    final RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null && context.mounted) {
      _handleMessage(initialMessage, context);
    }

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (context.mounted) {
        _handleMessage(message, context);
      }
    });
  }

  void _handleMessage(RemoteMessage message, BuildContext context) {
    final routeName = message.data['routeName'];
    if (routeName != null) {
      Navigator.pushNamed(context, routeName);
    }

    final url = message.data['url'];
    if (url != null) {
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
}
