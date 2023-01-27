import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../util/analytics_manager.dart';
import '../../../util/injection.dart';

const settingTitleTextStyle = TextStyle(
  fontSize: 14,
);
const settingDescriptionTextStyle = TextStyle(
  fontSize: 12,
  color: Colors.grey,
  height: 1.4,
);

class SettingTile extends StatefulWidget {
  final GestureTapCallback? onTap;
  final String title;
  final String? description;
  final String? disabledDescription;
  final String? preferenceKey;
  final ValueChanged<bool>? onSwitchChanged;
  final bool defaultValue;
  final Color? titleColor;
  final bool showArrow;

  const SettingTile({
    Key? key,
    this.onTap,
    required this.title,
    this.description,
    this.disabledDescription,
    this.preferenceKey,
    this.onSwitchChanged,
    this.defaultValue = true,
    this.titleColor,
    this.showArrow = false,
  }) : super(key: key);

  @override
  State<SettingTile> createState() => _SettingTileState();
}

class _SettingTileState extends State<SettingTile> {
  final SharedPreferences _sharedPreferences = getIt.get();

  bool _isSwitchEnabled = true;

  @override
  Widget build(BuildContext context) {
    final preferenceKey = widget.preferenceKey;
    if (preferenceKey != null) {
      _isSwitchEnabled =
          _sharedPreferences.getBool(preferenceKey) ?? widget.defaultValue;
    }
    return InkWell(
      onTap: widget.preferenceKey == null
          ? _onTap
          : () => _onSwitchChanged(!_isSwitchEnabled),
      splashColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: widget.description == null && widget.preferenceKey == null
              ? 16
              : 12,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: settingTitleTextStyle.copyWith(
                      color: widget.titleColor,
                    ),
                  ),
                  if (widget.description != null) const SizedBox(height: 4),
                  if (widget.description != null)
                    Text(
                      _getDescription(),
                      style: settingDescriptionTextStyle,
                    ),
                ],
              ),
            ),
            if (widget.preferenceKey != null || widget.showArrow)
              const SizedBox(width: 16),
            if (widget.preferenceKey != null)
              Switch(
                value: _isSwitchEnabled,
                onChanged: _onSwitchChanged,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            if (widget.showArrow)
              Icon(
                CupertinoIcons.chevron_right,
                color: Colors.black.withAlpha(40),
              ),
            if (widget.showArrow) const SizedBox(width: 2)
          ],
        ),
      ),
    );
  }

  void _onTap() {
    widget.onTap?.call();
    AnalyticsManager.logEvent(
      name: '[HomePage-settings] Setting tile button tapped',
      properties: {
        'title': widget.title,
      },
    );
  }

  String _getDescription() {
    final description = widget.description;
    final disabledDescription = widget.disabledDescription;
    if (disabledDescription == null) {
      return description ?? '';
    } else {
      if (_isSwitchEnabled) {
        return description ?? '';
      } else {
        return disabledDescription;
      }
    }
  }

  void _onSwitchChanged(bool isEnabled) {
    _sharedPreferences.setBool(widget.preferenceKey.toString(), isEnabled);
    setState(() {
      _isSwitchEnabled = isEnabled;
      widget.onSwitchChanged?.call(isEnabled);
    });

    AnalyticsManager.logEvent(
      name: '[HomePage-settings] Setting tile switch toggled',
      properties: {
        'title': widget.title,
        'is_enabled': isEnabled,
      },
    );
  }
}
