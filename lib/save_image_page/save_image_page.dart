import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

import '../model/exam_record.dart';
import '../model/subject.dart';
import '../util/menu_bar.dart';

const double _strokeWidth = 0.5;

class SaveImagePage extends StatefulWidget {
  static const routeName = '/record_detail/save_image';
  final ExamRecord examRecord;

  const SaveImagePage({
    Key? key,
    required this.examRecord,
  }) : super(key: key);

  @override
  State<SaveImagePage> createState() => _SaveImagePageState();
}

class _SaveImagePageState extends State<SaveImagePage> {
  bool showScore = true;
  bool showGrade = true;
  bool showDuration = true;
  bool showWrongProblems = true;

  @override
  void initState() {
    super.initState();
    showScore = widget.examRecord.score != null;
    showGrade = widget.examRecord.grade != null;
    showDuration = widget.examRecord.examDurationMinutes != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            MenuBar(
              title: '이미지 저장',
              actionButtons: [
                ActionButton(
                  tooltip: '공유하기',
                  icon: const Icon(Icons.share),
                  onPressed: () {},
                ),
                ActionButton(
                  tooltip: '저장하기',
                  icon: const Icon(Icons.download),
                  onPressed: () {},
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
          child: FittedBox(
            child: _buildPreview(),
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          child: Row(
            children: [
              const SizedBox(width: 12),
              _ChoiceChip(
                label: '점수',
                selected: showScore,
                onSelected: (value) => setState(() {
                  showScore = value;
                }),
              ),
              _ChoiceChip(
                label: '등급',
                selected: showGrade,
                onSelected: (value) => setState(() {
                  showGrade = value;
                }),
              ),
              _ChoiceChip(
                label: '시간',
                selected: showDuration,
                onSelected: (value) => setState(() {
                  showDuration = value;
                }),
              ),
              _ChoiceChip(
                label: '틀린 문제',
                selected: showWrongProblems,
                onSelected: (value) => setState(() {
                  showWrongProblems = value;
                }),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            '추후에 다양한 테마와 커스터마이징 기능이 추가될 예정입니다.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    return Container(
      width: 390,
      height: 390,
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
              top: BorderSide(color: Theme.of(context).primaryColor, width: 20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  DateFormat.yMEd('ko_KR').format(widget.examRecord.examStartedTime),
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
                      widget.examRecord.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.examRecord.subject.subjectName,
                      style: TextStyle(
                        color: Color(widget.examRecord.subject.firstColor),
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Divider(color: Theme.of(context).primaryColor, thickness: _strokeWidth),
              const SizedBox(height: 12),
              if (showScore || showGrade || showDuration)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (showScore)
                      SizedBox(
                        width: 72,
                        child: _InfoBox(
                          title: 'SCORE',
                          content: widget.examRecord.score.toString(),
                          suffix: '점',
                        ),
                      ),
                    if (showGrade)
                      SizedBox(
                        width: 72,
                        child: _InfoBox(
                          title: 'GRADE',
                          content: widget.examRecord.grade.toString(),
                          suffix: '등급',
                        ),
                      ),
                    if (showDuration)
                      SizedBox(
                        width: 72,
                        child: _InfoBox(
                          title: 'TIME',
                          content: widget.examRecord.examDurationMinutes.toString(),
                          suffix: '분',
                        ),
                      )
                  ],
                ),
              if (showScore || showGrade || showDuration) const SizedBox(height: 20),
              if (showWrongProblems)
                _InfoBox(
                  title: '틀린 문제',
                  content: widget.examRecord.wrongProblems.map((e) => e.problemNumber.toString()).join(', '),
                  longText: true,
                ),
              if (showWrongProblems) const SizedBox(height: 20),
              Expanded(
                child: _InfoBox(
                  title: '피드백',
                  content: widget.examRecord.feedback,
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

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _ChoiceChip({
    Key? key,
    required this.label,
    required this.selected,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: onSelected,
        selectedColor: Theme.of(context).primaryColor,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w700,
          color: selected ? Colors.white : Colors.black,
        ),
        pressElevation: 0,
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
