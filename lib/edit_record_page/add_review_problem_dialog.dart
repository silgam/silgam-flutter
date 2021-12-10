import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import '../model/problem.dart';

class AddReviewProblemDialog extends StatefulWidget {
  final Function(ReviewProblem) onReviewProblemAdded;

  const AddReviewProblemDialog({
    Key? key,
    required this.onReviewProblemAdded,
  }) : super(key: key);

  @override
  AddReviewProblemDialogState createState() => AddReviewProblemDialogState();
}

class AddReviewProblemDialogState extends State<AddReviewProblemDialog> {
  final List<String> _tempImagePaths = [];
  final _titleEditingController = TextEditingController();
  final _memoEditingController = TextEditingController();
  bool _isTitleEmpty = false;

  @override
  void initState() {
    super.initState();
    _titleEditingController.addListener(() {
      if (_isTitleEmpty) {
        setState(() {
          _isTitleEmpty = false;
        });
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
              child: _buildImages(),
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

  Widget _buildImages() {
    return Wrap(
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
              child: Image.file(
                File(imagePath),
                fit: BoxFit.cover,
              ),
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
    );
  }

  void _onImageTapped(String imagePath) {
    setState(() {
      _tempImagePaths.remove(imagePath);
    });
  }

  void _onImageAddButtonPressed() async {
    final picker = ImagePicker();
    List<XFile>? files = await picker.pickMultiImage();
    if (files == null) return;
    setState(() {
      _tempImagePaths.addAll(files.map((e) => e.path));
    });
  }

  void _onCancelButtonPressed() {
    Navigator.pop(context);
  }

  void _onConfirmButtonPressed() {
    if (_titleEditingController.text.isEmpty) {
      setState(() {
        _isTitleEmpty = true;
      });
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
