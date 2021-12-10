import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import '../model/problem.dart';
import '../model/subject.dart';

class EditRecordPage extends StatefulWidget {
  static const routeName = '/edit_record';
  final EditRecordPageArguments arguments;

  const EditRecordPage({
    Key? key,
    required this.arguments,
  }) : super(key: key);

  @override
  State<EditRecordPage> createState() => _EditRecordPageState();
}

class _EditRecordPageState extends State<EditRecordPage> {
  Subject _selectedSubject = Subject.language;
  DateTime _selectedDateTime = DateTime.now().resetSeconds();
  final List<WrongProblem> _wrongProblems = [];
  final List<ReviewProblem> _reviewProblems = [];

  final FocusNode _wrongProblemFocusNode = FocusNode();
  final TextEditingController _wrongProblemEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _wrongProblemFocusNode.addListener(() {
      _onWrongProblemSubmitted(_wrongProblemEditingController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  child: _buildForm(),
                ),
              ),
              const Divider(height: 1),
              _buildBottomButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        _buildSubTitle('모의고사 기록하기'),
        const TextField(
          style: TextStyle(
            fontSize: 24,
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration.collapsed(
            hintText: '모의고사 이름',
            border: InputBorder.none,
          ),
        ),
        const SizedBox(height: 16),
        _buildSubTitle('과목'),
        const SizedBox(height: 2),
        DropdownButtonHideUnderline(
          child: DropdownButton(
            value: _selectedSubject,
            onChanged: (Subject? newSubject) {
              setState(() {
                _selectedSubject = newSubject ?? Subject.language;
              });
            },
            items: Subject.values.map((subject) {
              return DropdownMenuItem(
                value: subject,
                child: Text(subject.name),
              );
            }).toList(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 8),
        _buildSubTitle('시험 시작 시각'),
        const SizedBox(height: 2),
        GestureDetector(
          onTap: () async {
            final dateTime = await DatePicker.showDateTimePicker(
              context,
              locale: LocaleType.ko,
              currentTime: _selectedDateTime,
            );
            if (dateTime == null) return;
            _selectedDateTime = dateTime;
            setState(() {});
          },
          child: Text(
            _selectedDateTime.toStringTrimmed(),
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 8),
        Wrap(
          spacing: 24,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSubTitle('시험 시간'),
                const SizedBox(height: 6),
                const SizedBox(
                  width: 60,
                  child: _OutlinedTextField(suffix: '분'),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSubTitle('점수'),
                const SizedBox(height: 6),
                const SizedBox(
                  width: 60,
                  child: _OutlinedTextField(suffix: '점'),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSubTitle('등급'),
                const SizedBox(height: 6),
                const SizedBox(
                  width: 56,
                  child: _OutlinedTextField(suffix: '등급'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 8),
        _buildSubTitle('틀린 문제'),
        Wrap(
          spacing: 8,
          runSpacing: -8,
          children: [
            for (final problem in _wrongProblems)
              Chip(
                label: Text('${problem.problemNumber}번'),
                onDeleted: () => _onChipDeleted(problem),
                labelPadding: const EdgeInsets.only(left: 8, right: 2),
                deleteIconColor: Colors.white54,
                backgroundColor: Theme.of(context).primaryColor,
                labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w400, height: 1.21),
              ),
            SizedBox(
              width: 80,
              child: RawKeyboardListener(
                focusNode: _wrongProblemFocusNode,
                onKey: _onWrongProblemEditingKeyDetected,
                child: TextField(
                  controller: _wrongProblemEditingController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: '번호 입력',
                    border: InputBorder.none,
                  ),
                  onEditingComplete: () {
                    // Required, prevent hiding keyboard
                  },
                  onChanged: _onWrongProblemEditingChanged,
                  onSubmitted: _onWrongProblemSubmitted,
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 8),
        _buildSubTitle('피드백'),
        const SizedBox(height: 8),
        const TextField(
          keyboardType: TextInputType.multiline,
          maxLines: null,
          minLines: 2,
          decoration: InputDecoration(
            isCollapsed: true,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 8),
        _buildSubTitle('복습할 문제'),
        const SizedBox(height: 2),
        GridView.extent(
          maxCrossAxisExtent: 400,
          childAspectRatio: 1.5,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final problem in _reviewProblems) _buildReviewProblemCard(problem),
            _buildReviewProblemAddCard(),
          ],
        )
      ],
    );
  }

  Widget _buildReviewProblemCard(ReviewProblem problem) {
    return Card(
      margin: const EdgeInsets.all(4),
      elevation: 0,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        side: BorderSide(width: 0.5, color: Colors.grey.shade300),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Stack(
        children: [
          if (problem.imagePaths.isNotEmpty)
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Image.file(
                File(problem.imagePaths.first),
                width: double.infinity,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          if (problem.imagePaths.isEmpty)
            Container(
              alignment: Alignment.center,
              child: Image.asset(
                'assets/app_icon/app_icon_transparent.png',
                width: 100,
                color: Colors.grey.shade100,
              ),
            ),
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(100)),
              color: Colors.white.withAlpha(200),
            ),
            child: Text(
              problem.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewProblemAddCard() {
    return GestureDetector(
      onTap: _onReviewProblemAddCardTapped,
      child: Card(
        margin: const EdgeInsets.all(4),
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 0.5, color: Colors.grey.shade300),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/add.svg',
              width: 36,
              color: Colors.grey.shade800,
            ),
            const SizedBox(width: 2),
            Text(
              '추가하기',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w100,
                height: 1.2,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.grey.shade600,
        fontWeight: FontWeight.w300,
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              '취소',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ),
        Expanded(
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('저장'),
          ),
        ),
      ],
    );
  }

  void _onChipDeleted(WrongProblem problem) {
    _wrongProblems.remove(problem);
    setState(() {});
  }

  void _onWrongProblemEditingKeyDetected(RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return;
    if (event.logicalKey == LogicalKeyboardKey.backspace && _wrongProblemEditingController.text.isEmpty) {
      _wrongProblems.removeLast();
      setState(() {});
    }
  }

  void _onWrongProblemEditingChanged(String text) {
    if (text.endsWith(' ')) {
      _onWrongProblemSubmitted(_wrongProblemEditingController.text);
      _wrongProblemEditingController.clear();
    }
  }

  void _onWrongProblemSubmitted(String text) {
    _wrongProblemEditingController.clear();

    int problemNumber = int.tryParse(text) ?? -1;
    if (problemNumber == -1) return;
    if (_wrongProblems.where((problem) {
      return problem.problemNumber == problemNumber;
    }).isNotEmpty) return;
    _wrongProblems.add(WrongProblem(problemNumber));
    setState(() {});
  }

  void _onReviewProblemAddCardTapped() {
    showDialog(
      context: context,
      builder: (context) {
        return _AddReviewProblemDialog(onReviewProblemAdded: _onReviewProblemAdded);
      },
    );
  }

  void _onReviewProblemAdded(ReviewProblem problem) {
    _reviewProblems.add(problem);
    setState(() {});
  }

  @override
  void dispose() {
    _wrongProblemFocusNode.dispose();
    super.dispose();
  }
}

class _OutlinedTextField extends StatelessWidget {
  final String suffix;

  const _OutlinedTextField({
    Key? key,
    required this.suffix,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        isCollapsed: true,
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Text(
            suffix,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w300,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        suffixIconConstraints: const BoxConstraints(minHeight: 0),
        contentPadding: const EdgeInsets.only(top: 4, bottom: 4, left: 8),
      ),
    );
  }
}

class _AddReviewProblemDialog extends StatefulWidget {
  final Function(ReviewProblem) onReviewProblemAdded;

  const _AddReviewProblemDialog({
    Key? key,
    required this.onReviewProblemAdded,
  }) : super(key: key);

  @override
  _AddReviewProblemDialogState createState() => _AddReviewProblemDialogState();
}

class _AddReviewProblemDialogState extends State<_AddReviewProblemDialog> {
  final List<String> _tempImagePaths = [];
  final _titleEditingController = TextEditingController();
  final _memoEditingController = TextEditingController();
  bool _isTitleEmpty = false;

  @override
  void initState() {
    super.initState();
    _titleEditingController.addListener(() {
      if (_isTitleEmpty) {
        _isTitleEmpty = false;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(left: 24, right: 24, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '복습할 문제 추가',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleEditingController,
              decoration: InputDecoration(
                hintText: '제목',
                errorText: _isTitleEmpty ? '제목을 입력해주세요' : null,
                isCollapsed: true,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _memoEditingController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              minLines: 2,
              decoration: const InputDecoration(
                hintText: '메모',
                isCollapsed: true,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '사진',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (String imagePath in _tempImagePaths)
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300, width: 0.5),
                      ),
                      child: GestureDetector(
                        onTap: () => _onImageTapped(imagePath),
                        child: Image.file(File(imagePath), fit: BoxFit.cover),
                      ),
                    ),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300, width: 0.5),
                    ),
                    child: IconButton(
                      onPressed: _onImageAddButtonPressed,
                      icon: SvgPicture.asset(
                        'assets/add.svg',
                        color: Colors.grey.shade600,
                      ),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _onCancelButtonPressed,
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: _onConfirmButtonPressed,
          child: const Text('추가하기'),
        ),
      ],
    );
  }

  void _onImageTapped(String imagePath) {
    _tempImagePaths.remove(imagePath);
    setState(() {});
  }

  void _onImageAddButtonPressed() async {
    final picker = ImagePicker();
    List<XFile>? files = await picker.pickMultiImage();
    if (files == null) return;
    _tempImagePaths.addAll(files.map((e) => e.path));
    setState(() {});
  }

  void _onCancelButtonPressed() {
    Navigator.pop(context);
  }

  void _onConfirmButtonPressed() {
    if (_titleEditingController.text.isEmpty) {
      _isTitleEmpty = true;
      setState(() {});
      return;
    }

    final problem = ReviewProblem(
      title: _titleEditingController.text,
      memo: _memoEditingController.text,
      imagePaths: _tempImagePaths,
    );
    widget.onReviewProblemAdded(problem);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleEditingController.dispose();
    super.dispose();
  }
}

class EditRecordPageArguments {}

extension on DateTime {
  String toStringTrimmed() {
    final string = toString();
    return string.substring(0, string.length - 7);
  }

  DateTime resetSeconds() {
    return DateTime(year, month, day, hour, minute);
  }
}
