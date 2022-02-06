import 'dart:io';

import 'package:flutter/services.dart';

class AndroidAudioManager {
  static const _platform = MethodChannel('com.seunghyun.silgam/audio');

  static Future<void> controlMediaVolume() async {
    if (Platform.isAndroid) {
      await _platform.invokeMethod('controlMediaVolume');
    }
  }

  static Future<void> controlDefaultVolume() async {
    if (Platform.isAndroid) {
      await _platform.invokeMethod('controlDefaultVolume');
    }
  }
}
