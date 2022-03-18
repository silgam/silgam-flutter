import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

import '../model/exam_record.dart';
import '../model/subject.dart';
import '../util/menu_bar.dart';

const double _strokeWidth = 0.5;

class SaveImagePage extends StatelessWidget {
  static const routeName = '/record_detail/save_image';
  final ExamRecord examRecord;

  const SaveImagePage({
    Key? key,
    required this.examRecord,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const MenuBar(title: '이미지 저장'),
            AspectRatio(
              aspectRatio: 1,
              child: _buildPreview(Theme.of(context).primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(Color primaryColor) {
    return Container(
      clipBehavior: Clip.hardEdge,
      alignment: Alignment.bottomCenter,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
      ),
      child: FractionallySizedBox(
        widthFactor: 0.8,
        heightFactor: 0.87,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            image: const DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage('assets/paper_texture.png'),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(30),
                offset: const Offset(4, 4),
                blurRadius: 20,
              ),
            ],
            border: Border(
              top: BorderSide(color: primaryColor, width: 20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  DateFormat.yMEd('ko_KR').format(examRecord.examStartedTime),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      examRecord.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      examRecord.subject.subjectName,
                      style: TextStyle(
                        color: Color(examRecord.subject.firstColor),
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Divider(color: primaryColor, thickness: _strokeWidth),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (examRecord.score != null)
                    SizedBox(
                      width: 72,
                      child: _InfoBox(
                        title: 'SCORE',
                        content: examRecord.score.toString(),
                        suffix: '점',
                      ),
                    ),
                  if (examRecord.grade != null)
                    SizedBox(
                      width: 72,
                      child: _InfoBox(
                        title: 'GRADE',
                        content: examRecord.grade.toString(),
                        suffix: '등급',
                      ),
                    ),
                  if (examRecord.examDurationMinutes != null)
                    SizedBox(
                      width: 72,
                      child: _InfoBox(
                        title: 'TIME',
                        content: examRecord.examDurationMinutes.toString(),
                        suffix: '분',
                      ),
                    )
                ],
              ),
              const SizedBox(height: 20),
              _InfoBox(
                title: '틀린 문제',
                content: examRecord.wrongProblems.map((e) => e.problemNumber.toString()).join(', '),
                longText: true,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _InfoBox(
                  title: '피드백',
                  content: examRecord.feedback,
                  longText: true,
                  expands: true,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String title;
  final String content;
  final String? suffix;
  final bool longText;
  final bool expands;

  const _InfoBox({
    Key? key,
    required this.title,
    required this.content,
    this.suffix,
    this.longText = false,
    this.expands = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController? controller;
    String? suffixCaptured = suffix;
    if (suffixCaptured != null) {
      controller = RichTextController(
        text: content + suffixCaptured,
        patternMatchMap: {
          RegExp(suffixCaptured): const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w300,
          ),
        },
        onMatch: (_) {},
      );
    }

    return TextFormField(
      controller: controller,
      initialValue: suffix == null ? content : null,
      textAlign: longText ? TextAlign.start : TextAlign.center,
      readOnly: true,
      enabled: false,
      maxLines: null,
      expands: expands,
      style: TextStyle(
        fontSize: longText ? 12 : 14,
        fontWeight: longText ? FontWeight.w500 : FontWeight.w500,
      ),
      decoration: InputDecoration(
        isCollapsed: true,
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: _strokeWidth,
          ),
        ),
        labelText: title,
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).primaryColor,
        ),
        contentPadding: EdgeInsets.only(
          top: longText ? 11 : 8,
          bottom: longText ? 10 : 7,
          left: longText ? 12 : 0,
          right: longText ? 12 : 0,
        ),
        floatingLabelAlignment: longText ? null : FloatingLabelAlignment.center,
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }
}

class SaveImagePageArguments {
  final ExamRecord recordToSave;

  const SaveImagePageArguments({
    required this.recordToSave,
  });
}
