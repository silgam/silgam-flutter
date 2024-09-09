import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../util/const.dart';
import '../../util/injection.dart';
import '../common/custom_menu_bar.dart';
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

  AnnouncementType? _selectedAnnouncementType = announcementTypes[0];

  @override
  void initState() {
    super.initState();

    final announcementTypeId =
        _sharedPreferences.getInt(PreferenceKey.announcementTypeId) ??
            announcementTypes[0].id;
    _selectedAnnouncementType = announcementTypes.firstWhereOrNull(
      (element) => element.id == announcementTypeId,
    );
  }

  void _onAnnouncementTypeChanged(AnnouncementType? value) {
    setState(() {
      _selectedAnnouncementType = value;
    });
    _sharedPreferences.setInt(
      PreferenceKey.announcementTypeId,
      value?.id ?? announcementTypes[0].id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomMenuBar(title: '타종 소리 설정'),
            Expanded(
              child: ListView(
                children: [
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Text(
                      '수능 타종 소리는 지역별로, 학교별로 다를 수 있어요.',
                      style:
                          TextStyle(height: 1.35, color: Colors.grey.shade800),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Text(
                      '수능장에서의 타종 소리는 평소 연습하던 환경과 다를 수 있으니 다양한 타종 소리로 연습하는 것을 추천드려요.',
                      style:
                          TextStyle(height: 1.35, color: Colors.grey.shade800),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
