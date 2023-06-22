import 'package:flutter/material.dart';

import '../../util/analytics_manager.dart';
import '../common/timeline_marker.dart';

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
      onTap: _onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.white12,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
            const SizedBox(height: 1),
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
      texts.add(
          Text(title.substring(0, splitIndex).trim(), style: defaultTextStyle));
      texts
          .add(Text(title.substring(splitIndex).trim(), style: smallTextStyle));
    }
    return texts;
  }

  void _onTap() {
    onTap();
    AnalyticsManager.logEvent(
      name: '[ClockPage] Timeline tile tapped',
      properties: {'title': title},
    );
  }
}

class TimelineConnector extends StatelessWidget {
  static const double _markerHeight = 13.0;
  static const double _markerWidth = 8.0;
  final int duration;
  final double progress;
  final Axis direction;
  final List<double> markerPositions;
  final bool unsetWidth;
  final bool unsetHeight;
  final Color enabledColor;

  const TimelineConnector(
    this.duration,
    this.progress, {
    this.direction = Axis.horizontal,
    this.markerPositions = const [],
    this.unsetWidth = false,
    this.unsetHeight = false,
    this.enabledColor = Colors.white,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size displaySize = MediaQuery.of(context).size;
    EdgeInsetsGeometry margin, connectorMargin;
    double? width, height, connecterWidth, connecterHeight;
    Alignment begin, end;
    if (direction == Axis.horizontal) {
      double widthScale = (displaySize.width / 120).constraint(3, 10);
      margin = const EdgeInsets.symmetric(horizontal: 1);
      connectorMargin = const EdgeInsets.symmetric(
        horizontal: _markerWidth / 2,
        vertical: 1,
      );
      width = duration * widthScale + connectorMargin.horizontal * 2;
      height = (1 + connectorMargin.vertical * 2) + _markerHeight * 2;
      connecterWidth = null;
      connecterHeight = 1;
      begin = Alignment.centerLeft;
      end = Alignment.centerRight;
    } else {
      double heightScale = (displaySize.height / 120).constraint(3, 10);
      margin = const EdgeInsets.symmetric(vertical: 1);
      connectorMargin = const EdgeInsets.symmetric(
        vertical: _markerWidth / 2,
        horizontal: 1,
      );
      height = duration * heightScale + connectorMargin.vertical * 2;
      width = (1 + connectorMargin.horizontal * 2) + _markerHeight * 2;
      connecterWidth = 1;
      connecterHeight = null;
      begin = Alignment.topCenter;
      end = Alignment.bottomCenter;
    }
    return Container(
      width: unsetWidth ? null : width,
      height: unsetHeight ? null : height,
      margin: margin,
      child: Flex(
        direction: flipAxis(direction),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: unsetHeight ? 0 : 1,
            child: Stack(
              children: markerPositions
                  .map(
                    (position) => Flex(
                      direction: direction,
                      children: [
                        if (position > 0)
                          Spacer(
                            flex: (position * 10000).toInt(),
                          ),
                        RotatedBox(
                          quarterTurns: direction == Axis.horizontal ? 0 : -1,
                          child: TimelineMarker(
                            width: _markerWidth,
                            height: _markerHeight,
                            color: _getTimelineColor(
                              position > progress,
                              enabledColor: enabledColor,
                            ),
                          ),
                        ),
                        if (position < 1)
                          Spacer(
                            flex: ((1 - position) * 10000).toInt(),
                          ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
          Container(
            width: connecterWidth,
            height: connecterHeight,
            margin: connectorMargin,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: begin,
                end: end,
                colors: [
                  _getTimelineColor(
                    false,
                    enabledColor: enabledColor,
                  ),
                  _getTimelineColor(
                    true,
                    enabledColor: enabledColor,
                  )
                ],
                stops: [progress, progress],
              ),
            ),
          ),
          if (!unsetHeight) const Spacer(),
        ],
      ),
    );
  }
}

Color _getTimelineColor(
  bool disabled, {
  Color enabledColor = Colors.white,
}) {
  if (disabled) return Colors.grey[700]!;
  return enabledColor;
}

extension on double {
  double constraint(double min, double max) {
    double result = this;
    if (result < min) result = min;
    if (result > max) result = max;
    return result;
  }
}
