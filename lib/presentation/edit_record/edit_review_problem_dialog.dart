import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ui/ui.dart';

import '../../model/problem.dart';
import '../../util/injection.dart';
import '../app/cubit/app_cubit.dart';

class EditReviewProblemDialog extends StatefulWidget {
  final ReviewProblemAddModeParams? reviewProblemAddModeParams;
  final ReviewProblemEditModeParams? reviewProblemEditModeParams;

  const EditReviewProblemDialog.add(
    this.reviewProblemAddModeParams, {
    super.key,
  }) : reviewProblemEditModeParams = null;

  const EditReviewProblemDialog.edit(
    this.reviewProblemEditModeParams, {
    super.key,
  }) : reviewProblemAddModeParams = null;

  @override
  EditReviewProblemDialogState createState() => EditReviewProblemDialogState();
}

class EditReviewProblemDialogState extends State<EditReviewProblemDialog> {
  final AppCubit _appCubit = getIt.get();
  final _titleEditingController = TextEditingController();
  final _memoEditingController = TextEditingController();
  final List<String> _tempImagePaths = [];

  bool _isTitleEmpty = true;
  bool _isTitleFirstEdit = true;
  bool _isChanged = false;

  @override
  void initState() {
    super.initState();

    final editModeParams = widget.reviewProblemEditModeParams;
    if (editModeParams != null) {
      _titleEditingController.text = editModeParams.initialData.title;
      _memoEditingController.text = editModeParams.initialData.memo;
      _tempImagePaths.addAll(editModeParams.initialData.imagePaths);
      _isTitleEmpty = _titleEditingController.text.isEmpty;
    }
  }

  void _onPopInvokedWithResult(bool value, _) {
    if (value) return;

    showDialog(
      context: context,
      routeSettings: const RouteSettings(
        name: 'edit_review_problem_dialog/exit_confirm_dialog',
      ),
      builder: (context) {
        return CustomAlertDialog(
          title: '아직 저장하지 않았어요!',
          content: '저장하지 않고 나가시겠어요?',
          actions: [
            CustomTextButton.secondary(
              text: '취소',
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            CustomTextButton.destructive(
              text: '저장하지 않고 나가기',
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog.customContent(
      title: '복습할 문제 추가',
      content: PopScope(
        canPop: !_isChanged,
        onPopInvokedWithResult: _onPopInvokedWithResult,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _titleEditingController,
                  onChanged: _onTitleChanged,
                  decoration: InputDecoration(
                    hintText: '제목 (문제 번호)',
                    isCollapsed: true,
                    contentPadding: const EdgeInsets.all(12),
                    errorStyle: const TextStyle(fontSize: 0, height: 0),
                    errorText: _isTitleEmpty && !_isTitleFirstEdit ? '' : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 0.5,
                        color: Theme.of(context).primaryColor,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
                    ),
                    errorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 0.5,
                        color: Colors.red,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                    ),
                    focusedErrorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 0.5,
                        color: Colors.red,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                    ),
                    hintStyle: const TextStyle(fontWeight: FontWeight.w300),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _memoEditingController,
                  onChanged: _onMemoChanged,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  minLines: 2,
                  decoration: InputDecoration(
                    hintText: '메모 (이 문제를 틀린 이유, 복습할 점을 적어보세요.)',
                    hintMaxLines: 3,
                    isCollapsed: true,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 0.5,
                        color: Theme.of(context).primaryColor,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                    hintStyle: const TextStyle(
                      fontWeight: FontWeight.w300,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '사진',
                  style: TextStyle(
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                      fontSize: 14),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  child: _buildImages(),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        if (widget.reviewProblemEditModeParams != null)
          CustomTextButton.destructive(
            text: '삭제',
            onPressed: _onDeleteButtonPressed,
          ),
        CustomTextButton.secondary(
          text: '취소',
          onPressed: _onCancelButtonPressed,
        ),
        CustomTextButton.primary(
          text: widget.reviewProblemAddModeParams == null ? '수정' : '추가',
          onPressed: _onConfirmButtonPressed,
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
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: GestureDetector(
              onTap: () => _onImageTapped(imagePath),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Builder(builder: (context) {
                    if (imagePath.startsWith('http')) {
                      return CachedNetworkImage(
                        imageUrl: imagePath,
                        fit: BoxFit.cover,
                        progressIndicatorBuilder: (_, __, progress) => Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              value: progress.progress,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 18,
                            color: Colors.grey.shade200,
                          ),
                        ),
                      );
                    } else {
                      return Image.file(
                        File(imagePath),
                        fit: BoxFit.cover,
                      );
                    }
                  }),
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
            border: Border.all(color: Colors.grey.shade300),
            color: Colors.white,
          ),
          child: IconButton(
            onPressed: _onImageAddButtonPressed,
            icon: SvgPicture.asset(
              'assets/add.svg',
              colorFilter: ColorFilter.mode(
                Colors.grey.shade600,
                BlendMode.srcIn,
              ),
            ),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
        ),
      ],
    );
  }

  void _onTitleChanged(String title) {
    _isTitleFirstEdit = false;

    if (!_isChanged) {
      setState(() {
        _isChanged = true;
      });
    }

    if (_isTitleEmpty && _titleEditingController.text.isNotEmpty) {
      setState(() {
        _isTitleEmpty = false;
      });
      return;
    }
    if (!_isTitleEmpty && _titleEditingController.text.isEmpty) {
      setState(() {
        _isTitleEmpty = true;
      });
      return;
    }
  }

  void _onMemoChanged(_) {
    if (!_isChanged) {
      setState(() {
        _isChanged = true;
      });
    }
  }

  void _onImageTapped(String imagePath) {
    if (_appCubit.state.isOffline) {
      EasyLoading.showToast(
        '오프라인 상태에서는 사진을 삭제할 수 없어요.',
        dismissOnTap: true,
      );
      return;
    }

    setState(() {
      _isChanged = true;
      _tempImagePaths.remove(imagePath);
    });
  }

  void _onImageAddButtonPressed() async {
    if (_appCubit.state.isOffline) {
      EasyLoading.showToast(
        '오프라인 상태에서는 사진을 추가할 수 없어요.',
        dismissOnTap: true,
      );
      return;
    }

    final picker = ImagePicker();
    List<XFile> files = await picker.pickMultiImage();
    setState(() {
      _isChanged = true;
      _tempImagePaths.addAll(files.map((e) => e.path));
    });
  }

  void _onDeleteButtonPressed() {
    if (_appCubit.state.isOffline && _tempImagePaths.isNotEmpty) {
      EasyLoading.showToast(
        '오프라인 상태에서는 사진이 포함된 복습할 문제를 삭제할 수 없어요.',
        dismissOnTap: true,
      );
      return;
    }

    final reviewProblemEditModeParams = widget.reviewProblemEditModeParams;
    reviewProblemEditModeParams
        ?.onReviewProblemDeleted(reviewProblemEditModeParams.initialData);

    Navigator.pop(context);
  }

  void _onCancelButtonPressed() {
    Navigator.maybePop(context);
  }

  void _onConfirmButtonPressed() {
    if (_isTitleEmpty) {
      setState(() {
        _isTitleFirstEdit = false;
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
    reviewProblemEditModeParams?.onReviewProblemEdited(
        reviewProblemEditModeParams.initialData, newProblem);

    Navigator.pop(context);
  }
}

class ReviewProblemAddModeParams {
  final Function(ReviewProblem) onReviewProblemAdded;

  const ReviewProblemAddModeParams({
    required this.onReviewProblemAdded,
  });
}

class ReviewProblemEditModeParams {
  final Function(ReviewProblem oldProblem, ReviewProblem newProblem)
      onReviewProblemEdited;
  final Function(ReviewProblem) onReviewProblemDeleted;
  final ReviewProblem initialData;

  const ReviewProblemEditModeParams({
    required this.onReviewProblemEdited,
    required this.onReviewProblemDeleted,
    required this.initialData,
  });
}
