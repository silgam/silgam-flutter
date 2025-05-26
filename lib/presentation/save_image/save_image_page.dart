import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rich_text_controller/rich_text_controller.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ui/ui.dart';

import '../../model/exam_record.dart';
import '../../util/analytics_manager.dart';

const double _strokeWidth = 0.5;

class SaveImagePage extends StatefulWidget {
  static const routeName = '/record_detail/save_image';
  final ExamRecord examRecord;

  const SaveImagePage({super.key, required this.examRecord});

  @override
  State<SaveImagePage> createState() => _SaveImagePageState();
}

class _SaveImagePageState extends State<SaveImagePage> {
  final ScreenshotController _screenshotController = ScreenshotController();
  final GlobalKey _shareButtonKey = GlobalKey();
  bool showScore = true;
  bool showGrade = true;
  bool showDuration = true;
  bool showWrongProblems = true;
  bool showFeedback = true;

  @override
  void initState() {
    super.initState();
    showScore = widget.examRecord.score != null;
    showGrade = widget.examRecord.grade != null;
    showDuration = widget.examRecord.examDurationMinutes != null;
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      title: '이미지 저장',
      onBackPressed: () => Navigator.of(context).pop(),
      appBarActions: [
        AppBarAction(
          key: _shareButtonKey,
          iconData: Icons.share,
          tooltip: '공유하기',
          onPressed: onShareButtonPressed,
        ),
        AppBarAction(iconData: Icons.download, tooltip: '저장하기', onPressed: onSaveButtonPressed),
      ],
      child: SingleChildScrollView(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Divider(color: Colors.grey.shade300, height: 0.5, thickness: 0.5),
        MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1)),
          child: FittedBox(
            child: Screenshot(controller: _screenshotController, child: _buildPreview()),
          ),
        ),
        Divider(color: Colors.grey.shade300, height: 0.5, thickness: 0.5),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          physics: const AlwaysScrollableScrollPhysics(),
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
              _ChoiceChip(
                label: '피드백',
                selected: showFeedback,
                onSelected: (value) => setState(() {
                  showFeedback = value;
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
      decoration: BoxDecoration(color: Colors.grey.shade50),
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
            border: Border(top: BorderSide(color: Theme.of(context).primaryColor, width: 20)),
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
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade800,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.examRecord.exam.name,
                      style: TextStyle(color: Color(widget.examRecord.exam.color), fontSize: 9),
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
                      ),
                  ],
                ),
              if (showScore || showGrade || showDuration) const SizedBox(height: 20),
              if (showWrongProblems)
                _InfoBox(
                  title: '틀린 문제',
                  content: widget.examRecord.wrongProblems
                      .map((e) => e.problemNumber.toString())
                      .join(', '),
                  longText: true,
                ),
              if (showWrongProblems) const SizedBox(height: 20),
              if (showFeedback)
                Expanded(
                  child: _InfoBox(
                    title: '피드백',
                    content: widget.examRecord.feedback,
                    longText: true,
                    expands: true,
                  ),
                ),
              if (showFeedback) const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void onShareButtonPressed() async {
    AnalyticsManager.logEvent(name: '[SaveExamRecordImagePage] Share button tapped');

    final temporaryDirectory = await getTemporaryDirectory();
    final imagePath =
        await _screenshotController.captureAndSave(temporaryDirectory.path, pixelRatio: 4) ?? '';
    RenderBox shareButtonBox = _shareButtonKey.currentContext?.findRenderObject() as RenderBox;
    Offset shareButtonPosition = shareButtonBox.localToGlobal(Offset.zero);
    Rect shareButtonRect = Rect.fromLTWH(
      shareButtonPosition.dx,
      shareButtonPosition.dy,
      shareButtonBox.paintBounds.width,
      shareButtonBox.paintBounds.height,
    );
    await Share.shareXFiles(
      [XFile(imagePath)],
      text: widget.examRecord.title,
      sharePositionOrigin: shareButtonRect,
    );
    await File(imagePath).delete();
  }

  void onSaveButtonPressed() async {
    AnalyticsManager.logEvent(name: '[SaveExamRecordImagePage] Save button tapped');

    final imageBytes = await _screenshotController.capture(pixelRatio: 4);
    if (imageBytes == null) {
      throw Exception('Capture failed: return value is null');
    }

    final hasAccess = await Gal.hasAccess(toAlbum: true);
    if (!hasAccess) {
      await Gal.requestAccess(toAlbum: true);
    }
    await Gal.putImageBytes(imageBytes, name: widget.examRecord.title, album: '실감');

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('이미지가 저장되었습니다.')));
  }
}

class _InfoBox extends StatelessWidget {
  final String title;
  final String content;
  final String? suffix;
  final bool longText;
  final bool expands;

  const _InfoBox({
    required this.title,
    required this.content,
    this.suffix,
    this.longText = false,
    this.expands = false,
  });

  @override
  Widget build(BuildContext context) {
    TextEditingController? controller;
    String? suffixCaptured = suffix;
    if (suffixCaptured != null) {
      controller = RichTextController(
        text: content + suffixCaptured,
        targetMatches: [
          MatchTargetItem(
            regex: RegExp(suffixCaptured),
            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w300),
          ),
        ],
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
        color: Colors.grey.shade800,
      ),
      decoration: InputDecoration(
        isCollapsed: true,
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: _strokeWidth),
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

  const _ChoiceChip({required this.label, required this.selected, required this.onSelected});

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

  const SaveImagePageArguments({required this.recordToSave});
}
