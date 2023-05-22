import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../model/exam_record.dart';
import '../../common/dialog.dart';
import '../../common/material_hero.dart';

class RecordTile extends StatefulWidget {
  final ExamRecord record;
  final GestureTapCallback onTileTap;
  final bool isLocked;

  const RecordTile({
    Key? key,
    required this.record,
    required this.onTileTap,
    required this.isLocked,
  }) : super(key: key);

  @override
  State<RecordTile> createState() => RecordTileState();
}

class RecordTileState extends State<RecordTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(blurRadius: 8, color: Colors.grey.shade200),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              alignment: Alignment.centerRight,
              child: Container(
                width: 2,
                color: Color(widget.record.getGradeColor()),
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.isLocked ? null : widget.onTileTap,
              splashColor: Colors.transparent,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: _buildContent(),
              ),
            ),
          ),
          if (widget.isLocked)
            Positioned.fill(
              child: InkWell(
                onTap: () => showExamRecordLimitInfoDialog(context),
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                      ),
                      child: Icon(
                        Icons.lock_outline,
                        size: 20,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MaterialHero(
                tag: 'time ${widget.record.hashCode}',
                child: Text(
                  DateFormat.yMEd('ko_KR')
                      .add_Hm()
                      .format(widget.record.examStartedTime),
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: MaterialHero(
                      tag: 'title ${widget.record.hashCode}',
                      child: Text(
                        widget.record.title,
                        overflow: TextOverflow.ellipsis,
                        textWidthBasis: TextWidthBasis.longestLine,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  MaterialHero(
                    tag: 'subject ${widget.record.hashCode}',
                    child: Text(
                      widget.record.subject.subjectName,
                      style: TextStyle(
                        color: Color(widget.record.subject.firstColor),
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              if (widget.record.feedback.isNotEmpty) const SizedBox(height: 6),
              if (widget.record.feedback.isNotEmpty)
                Text(
                  widget.record.feedback,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 11,
                  ),
                )
            ],
          ),
        ),
        const SizedBox(width: 12),
        _buildScoreGradeWidget(),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildScoreGradeWidget() {
    int? score = widget.record.score;
    int? grade = widget.record.grade;

    final List<TextSpan> textSpans = [];
    TextStyle smallTextStyle = TextStyle(
      fontSize: 12,
      color: Colors.grey.shade700,
    );

    if (score != null) {
      textSpans.add(TextSpan(text: score.toString()));
      textSpans.add(
        TextSpan(
          text: ' 점',
          style: smallTextStyle,
        ),
      );
    }
    if (score != null && grade != null) {
      textSpans.add(const TextSpan(text: '\n'));
    }
    if (grade != null) {
      textSpans.add(TextSpan(text: grade.toString()));
      textSpans.add(
        TextSpan(
          text: ' 등급',
          style: smallTextStyle,
        ),
      );
    }

    TextStyle? defaultTextStyle = Theme.of(context).primaryTextTheme.bodyLarge;
    return RichText(
      textAlign: TextAlign.end,
      text: TextSpan(
        style: defaultTextStyle?.copyWith(
          fontWeight: FontWeight.w300,
          fontSize: 18,
          color: Colors.black,
        ),
        children: textSpans,
      ),
    );
  }
}
