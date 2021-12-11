import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import '../model/problem.dart';

class EditReviewProblemDialog extends StatefulWidget {
  final ReviewProblemAddModeParams? reviewProblemAddModeParams;
  final ReviewProblemEditModeParams? reviewProblemEditModeParams;

  const EditReviewProblemDialog.add(this.reviewProblemAddModeParams, {Key? key})
      : reviewProblemEditModeParams = null,
        super(key: key);

  const EditReviewProblemDialog.edit(this.reviewProblemEditModeParams, {Key? key})
      : reviewProblemAddModeParams = null,
        super(key: key);

  @override
  EditReviewProblemDialogState createState() => EditReviewProblemDialogState();
}

class EditReviewProblemDialogState extends State<EditReviewProblemDialog> {
  final _titleEditingController = TextEditingController();
  final _memoEditingController = TextEditingController();
  final List<String> _tempImagePaths = [];

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

    final editModeParams = widget.reviewProblemEditModeParams;
    if (editModeParams != null) {
      _titleEditingController.text = editModeParams.initialData.title;
      _memoEditingController.text = editModeParams.initialData.memo ?? '';
      _tempImagePaths.addAll(editModeParams.initialData.imagePaths);
    }
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
        if (widget.reviewProblemEditModeParams != null)
          TextButton(
            onPressed: _onDeleteButtonPressed,
            child: Text(
              '삭제',
              style: TextStyle(color: Colors.red.shade600),
            ),
          ),
        TextButton(
          onPressed: _onCancelButtonPressed,
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: _onConfirmButtonPressed,
          child: Text(widget.reviewProblemAddModeParams == null ? '수정' : '추가'),
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
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.all(2),
                    child: Icon(
                      Icons.clear,
                      size: 16,
                      color: Colors.black.withAlpha(180),
                    ),
                  )
                ],
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

  void _onDeleteButtonPressed() {
    final reviewProblemEditModeParams = widget.reviewProblemEditModeParams;
    reviewProblemEditModeParams?.onReviewProblemDeleted(reviewProblemEditModeParams.initialData);

    Navigator.pop(context);
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

    final newProblem = ReviewProblem(
      title: _titleEditingController.text,
      memo: _memoEditingController.text,
      imagePaths: _tempImagePaths,
    );

    final reviewProblemAddModeParams = widget.reviewProblemAddModeParams;
    final reviewProblemEditModeParams = widget.reviewProblemEditModeParams;

    reviewProblemAddModeParams?.onReviewProblemAdded(newProblem);
    reviewProblemEditModeParams?.onReviewProblemEdited(reviewProblemEditModeParams.initialData, newProblem);

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleEditingController.dispose();
    super.dispose();
  }
}

class ReviewProblemAddModeParams {
  final Function(ReviewProblem) onReviewProblemAdded;

  const ReviewProblemAddModeParams({
    required this.onReviewProblemAdded,
  });
}

class ReviewProblemEditModeParams {
  final Function(ReviewProblem oldProblem, ReviewProblem newProblem) onReviewProblemEdited;
  final Function(ReviewProblem) onReviewProblemDeleted;
  final ReviewProblem initialData;

  const ReviewProblemEditModeParams({
    required this.onReviewProblemEdited,
    required this.onReviewProblemDeleted,
    required this.initialData,
  });
}
