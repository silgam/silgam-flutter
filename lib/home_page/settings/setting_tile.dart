import 'package:flutter/material.dart';

import '../../util/shared_preferences_holder.dart';

class SettingTile extends StatefulWidget {
  final GestureTapCallback? onTap;
  final String title;
  final String? description;
  final String? disabledDescription;
  final String? preferenceKey;

  const SettingTile({
    Key? key,
    this.onTap,
    required this.title,
    this.description,
    this.disabledDescription,
    this.preferenceKey,
  }) : super(key: key);

  @override
  State<SettingTile> createState() => _SettingTileState();
}

class _SettingTileState extends State<SettingTile> {
  bool _isSwitchEnabled = true;

  @override
  void initState() {
    super.initState();
    final preferenceKey = widget.preferenceKey;
    if (preferenceKey != null) {
      _isSwitchEnabled = SharedPreferencesHolder.get.getBool(preferenceKey) ?? true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.preferenceKey == null ? widget.onTap : () => _onSwitchChanged(!_isSwitchEnabled),
      splashColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: widget.description == null && widget.preferenceKey == null ? 16 : 12,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title),
                  if (widget.description != null)
                    Text(
                      _getDescription(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
            if (widget.preferenceKey != null)
              Switch(
                value: _isSwitchEnabled,
                onChanged: _onSwitchChanged,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )
          ],
        ),
      ),
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
    SharedPreferencesHolder.get.setBool(widget.preferenceKey.toString(), isEnabled);
    setState(() {
      _isSwitchEnabled = isEnabled;
    });
  }
}
