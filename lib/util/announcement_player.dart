import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../presentation/announcement_setting/announcement_type.dart';
import 'const.dart';

const _announcementsAssetPath = 'assets/announcements';

@injectable
class AnnouncementPlayer extends AudioPlayer {
  final SharedPreferences _sharedPreferences;

  late final int _announcementTypeId =
      _sharedPreferences.getInt(PreferenceKey.announcementTypeId) ??
          defaultAnnouncementType.id;

  AnnouncementPlayer(this._sharedPreferences) {
    if (!kIsWeb && Platform.isAndroid) setVolume(0.4);
  }

  Future<Duration?> setAnnouncement(
    String fileName, {
    int? announcementTypeId,
  }) {
    return setAsset(
        '$_announcementsAssetPath/${announcementTypeId ?? _announcementTypeId}_$fileName');
  }
}
