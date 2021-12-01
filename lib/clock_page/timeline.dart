import 'package:flutter/material.dart';

class TimelineTile extends StatelessWidget {
  final String time;
  final String title;
  final bool disabled;

  const TimelineTile(this.time, this.title, this.disabled, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          time,
          style: TextStyle(
            color: _getTimelineColor(disabled),
            fontWeight: FontWeight.w300,
            fontSize: 12,
          ),
        ),
        Column(children: _buildTitleTexts()),
      ],
    );
  }

  List<Text> _buildTitleTexts() {
    final texts = <Text>[];
    final regex = RegExp(r"\(([^)]+)\)");
    final allMatches = regex.allMatches(title);
    final defaultTextStyle = TextStyle(
      color: _getTimelineColor(disabled),
      fontWeight: FontWeight.w300,
      fontSize: 16,
    );
    final smallTextStyle = TextStyle(
      color: _getTimelineColor(disabled),
      fontWeight: FontWeight.w100,
      fontSize: 10,
    );
    if (allMatches.isEmpty) {
      texts.add(Text(title, style: defaultTextStyle));
    } else {
      final splitIndex = allMatches.last.start;
      texts.add(Text(title.substring(0, splitIndex).trim(), style: defaultTextStyle));
      texts.add(Text(title.substring(splitIndex).trim(), style: smallTextStyle));
    }
    return texts;
  }
}

class TimelineConnector extends StatelessWidget {
  final int duration;
  final double progress;

  const TimelineConnector(this.duration, this.progress, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        height: 1,
        width: duration * 3.0,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_getTimelineColor(false), _getTimelineColor(true)],
            stops: [progress, progress],
          ),
        ),
      ),
    );
  }
}

Color _getTimelineColor(bool disabled) {
  if (disabled) return Colors.grey[700]!;
  return Colors.white;
}
