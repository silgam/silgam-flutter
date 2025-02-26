import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ui/ui.dart';

import '../../model/subject.dart';
import '../../util/analytics_manager.dart';
import '../../util/announcement_player.dart';
import '../../util/const.dart';
import '../../util/injection.dart';
import 'announcement_type.dart';

class AnnouncementSettingPage extends StatefulWidget {
  const AnnouncementSettingPage({super.key});

  static const routeName = '/announcement_setting';

  @override
  State<AnnouncementSettingPage> createState() =>
      _AnnouncementSettingPageState();
}

class _AnnouncementSettingPageState extends State<AnnouncementSettingPage> {
  final SharedPreferences _sharedPreferences = getIt.get();
  final AnnouncementPlayer _announcementPlayer = getIt.get();

  AnnouncementType? _selectedAnnouncementType = defaultAnnouncementType;

  @override
  void initState() {
    super.initState();

    final announcementTypeId =
        _sharedPreferences.getInt(PreferenceKey.announcementTypeId) ??
        defaultAnnouncementType.id;
    _selectedAnnouncementType = announcementTypes.firstWhereOrNull(
      (element) => element.id == announcementTypeId,
    );
  }

  @override
  void dispose() async {
    super.dispose();

    await _announcementPlayer.stop();
    await _announcementPlayer.dispose();
  }

  void _onAnnouncementTypeChanged(AnnouncementType? announcementType) {
    setState(() {
      _selectedAnnouncementType = announcementType;
    });

    final announcementTypeId =
        announcementType?.id ?? defaultAnnouncementType.id;
    _sharedPreferences.setInt(
      PreferenceKey.announcementTypeId,
      announcementTypeId,
    );

    _announcementPlayer
      ..setAnnouncement(
        Subject.language.defaultAnnouncements[0].fileName!,
        announcementTypeId: announcementTypeId,
      )
      ..play();

    AnalyticsManager.logEvent(
      name: '[AnnouncementSettingPage] Announcement Type Changed',
      properties: {'announcementTypeId': announcementTypeId},
    );
    AnalyticsManager.setPeopleProperty('Announcement Type', announcementTypeId);
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: '타종 소리 설정',
      onBackPressed: () => Navigator.of(context).pop(),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Text(
                '수능 시험장에서의 타종 소리는 지역별로 다를 수 있어요. 혹시 모를 상황에 대비해 다양한 타종 소리로 연습해보세요.',
                style: TextStyle(height: 1.35, color: Colors.grey.shade800),
              ),
            ),
            const SizedBox(height: 18),
            Divider(
              indent: 16,
              endIndent: 16,
              height: 1,
              thickness: 1,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 4),
            for (var announcementType in announcementTypes)
              RadioListTile(
                title: Text(announcementType.title),
                subtitle: Text(announcementType.description),
                value: announcementType,
                groupValue: _selectedAnnouncementType,
                onChanged: _onAnnouncementTypeChanged,
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
