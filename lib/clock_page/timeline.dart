import 'package:flutter/material.dart';

class TimelineTile extends StatelessWidget {
  final GestureTapCallback onTap;
  final String time;
  final String title;
  final bool disabled;

  const TimelineTile({
    Key? key,
    required this.onTap,
    required this.time,
    required this.title,
    required this.disabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.white12,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Column(
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
        ),
      ),
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
  final Axis direction;

  const TimelineConnector(
    this.duration,
    this.progress, {
    this.direction = Axis.horizontal,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size displaySize = MediaQuery.of(context).size;
    double width, height;
    Alignment begin, end;
    if (direction == Axis.horizontal) {
      double widthScale = (displaySize.width / 120).constraint(3, 10);
      width = duration * widthScale;
      height = 1;
      begin = Alignment.centerLeft;
      end = Alignment.centerRight;
    } else {
      double heightScale = (displaySize.height / 120).constraint(3, 10);
      height = duration * heightScale;
      width = 1;
      begin = Alignment.topCenter;
      end = Alignment.bottomCenter;
    }
    return Flexible(
      child: Container(
        margin: const EdgeInsets.all(4),
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: begin,
            end: end,
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

extension on double {
  double constraint(double min, double max) {
    double result = this;
    if (result < min) result = min;
    if (result > max) result = max;
    return result;
  }
}
