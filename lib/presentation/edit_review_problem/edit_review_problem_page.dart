import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ui/ui.dart';

import '../../model/problem.dart';
import '../../util/injection.dart';
import '../app/cubit/app_cubit.dart';

typedef ReviewProblemAddCallback = Function(ReviewProblem reviewProblem);

typedef ReviewProblemAddModeParams = ({
  ReviewProblemAddCallback onReviewProblemAdd,
});

typedef ReviewProblemEditCallback = Function(
  ReviewProblem oldReviewProblem,
  ReviewProblem newReviewProblem,
);

typedef ReviewProblemDeleteCallback = Function(ReviewProblem reviewProblem);

typedef ReviewProblemEditModeParams = ({
  ReviewProblem initialData,
  ReviewProblemEditCallback onReviewProblemEdit,
  ReviewProblemDeleteCallback onReviewProblemDelete,
});

class EditReviewProblemPage extends StatefulWidget {
  final ReviewProblemAddModeParams? reviewProblemAddModeParams;
  final ReviewProblemEditModeParams? reviewProblemEditModeParams;

  const EditReviewProblemPage.add({
    super.key,
    required ReviewProblemAddCallback onReviewProblemAdd,
  })  : reviewProblemAddModeParams = (onReviewProblemAdd: onReviewProblemAdd),
        reviewProblemEditModeParams = null;

  const EditReviewProblemPage.edit({
    super.key,
    required ReviewProblem initialData,
    required ReviewProblemEditCallback onReviewProblemEdit,
    required ReviewProblemDeleteCallback onReviewProblemDelete,
  })  : reviewProblemAddModeParams = null,
        reviewProblemEditModeParams = (
          initialData: initialData,
          onReviewProblemEdit: onReviewProblemEdit,
          onReviewProblemDelete: onReviewProblemDelete,
        );

  static const String routeName = '/edit_review_problem';

  @override
  EditReviewProblemPageState createState() => EditReviewProblemPageState();
}

class EditReviewProblemPageState extends State<EditReviewProblemPage> {
  final AppCubit _appCubit = getIt.get();
  final GlobalKey<FormBuilderState> _formKey = GlobalKey();

  final String _titleFieldName = 'title';
  final String _memoFieldName = 'memo';
  final String _imagePathsFieldName = 'imagePaths';

  late final ReviewProblem? _initialData =
      widget.reviewProblemEditModeParams?.initialData;
  late final String? _initialTitle = _initialData?.title;
  late final String? _initialMemo = _initialData?.memo;
  late final List<String> _initialImagePaths = _initialData?.imagePaths ?? [];

  bool _isChanged = false;

  void _onPopInvokedWithResult(bool didPop, _) {
    if (didPop) return;

    showDialog(
      context: context,
      routeSettings: const RouteSettings(
        name: '${EditReviewProblemPage.routeName}/exit_confirm_dialog',
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

  void _onImageRemove(String imagePath) {
    if (_appCubit.state.isOffline) {
      EasyLoading.showToast(
        '오프라인 상태에서는 사진을 삭제할 수 없어요.',
        dismissOnTap: true,
      );
      return;
    }

    final field = _formKey.currentState?.fields[_imagePathsFieldName];
    final List<String> newImagePaths = [...?field?.value];
    newImagePaths.remove(imagePath);
    field?.didChange(newImagePaths);
  }

  void _onImageAddButtonTap() async {
    if (_appCubit.state.isOffline) {
      EasyLoading.showToast(
        '오프라인 상태에서는 사진을 추가할 수 없어요.',
        dismissOnTap: true,
      );
      return;
    }

    final picker = ImagePicker();
    List<XFile> files = await picker.pickMultiImage();
    if (files.isEmpty) return;

    final field = _formKey.currentState?.fields[_imagePathsFieldName];
    final List<String> newImagePaths = [...?field?.value];
    newImagePaths.addAll(files.map((e) => e.path));
    field?.didChange(newImagePaths);
  }

  void _onDeleteButtonPressed() {
    if (_appCubit.state.isOffline && _initialImagePaths.isNotEmpty) {
      EasyLoading.showToast(
        '오프라인 상태에서는 사진이 포함된 복습할 문제를 삭제할 수 없어요.',
        dismissOnTap: true,
      );
      return;
    }

    showDialog(
      context: context,
      routeSettings: const RouteSettings(
        name: '${EditReviewProblemPage.routeName}/delete_confirm_dialog',
      ),
      builder: (context) {
        return CustomAlertDialog(
          title: '정말 이 복습할 문제를 삭제하실 건가요?',
          content: _formKey.currentState?.fields[_titleFieldName]?.value,
          actions: [
            CustomTextButton.secondary(
              text: '취소',
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            CustomTextButton.destructive(
              text: '삭제',
              onPressed: () {
                final reviewProblemEditModeParams =
                    widget.reviewProblemEditModeParams;
                reviewProblemEditModeParams?.onReviewProblemDelete(
                    reviewProblemEditModeParams.initialData);
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _onCancelButtonPressed() {
    Navigator.maybePop(context);
  }

  void _onConfirmButtonPressed() {
    final isFormValid = _formKey.currentState?.saveAndValidate() ?? false;
    if (!isFormValid) return;

    final Map<String, dynamic>? values = _formKey.currentState?.value;

    final newProblem = ReviewProblem(
      title: values?[_titleFieldName],
      memo: values?[_memoFieldName] ?? '',
      imagePaths: values?[_imagePathsFieldName],
    );

    widget.reviewProblemAddModeParams?.onReviewProblemAdd(newProblem);

    final reviewProblemEditModeParams = widget.reviewProblemEditModeParams;
    reviewProblemEditModeParams?.onReviewProblemEdit(
        reviewProblemEditModeParams.initialData, newProblem);

    Navigator.pop(context);
  }

  Widget _buildImagesField() {
    return FormBuilderField(
      name: _imagePathsFieldName,
      initialValue: _initialImagePaths,
      builder: (field) {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final String imagePath in field.value ?? [])
              Container(
                width: 50,
                height: 50,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  border: Border.all(width: 0.5, color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.white,
                ),
                child: GestureDetector(
                  onTap: () => _onImageRemove(imagePath),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (imagePath.startsWith('http'))
                        CachedNetworkImage(
                          imageUrl: imagePath,
                          fit: BoxFit.cover,
                          progressIndicatorBuilder: (_, __, progress) {
                            return Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  value: progress.progress,
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                          errorWidget: (_, __, ___) {
                            return Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                size: 18,
                                color: Colors.grey.shade400,
                              ),
                            );
                          },
                        )
                      else
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
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Material(
              clipBehavior: Clip.hardEdge,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: BorderSide(width: 0.5, color: Colors.grey.shade300),
              ),
              child: InkWell(
                onTap: _onImageAddButtonTap,
                splashFactory: NoSplash.splashFactory,
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: Icon(
                    CupertinoIcons.add,
                    size: 20,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildForm() {
    return FormBuilder(
      key: _formKey,
      canPop: !_isChanged,
      onPopInvokedWithResult: _onPopInvokedWithResult,
      onChanged: () {
        if (_isChanged) return;

        setState(() {
          _isChanged = true;
        });
      },
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          FormItem(
            label: '제목',
            isRequired: true,
            child: FormTextField(
              name: _titleFieldName,
              initialValue: _initialTitle,
              hintText: '1번, 3~5번',
              textInputAction: TextInputAction.next,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(errorText: '제목을 입력해주세요.'),
                FormBuilderValidators.maxLength(100,
                    errorText: '100자 이하로 입력해주세요.'),
              ]),
            ),
          ),
          const SizedBox(height: 20),
          FormItem(
            label: '메모',
            child: FormTextField(
              name: _memoFieldName,
              initialValue: _initialMemo,
              hintText: '이 문제를 틀린 이유, 복습할 점을 적어보세요.',
              minLines: 2,
              maxLines: null,
            ),
          ),
          const SizedBox(height: 20),
          FormItem(
            label: '사진',
            child: _buildImagesField(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: PageLayout(
        title: widget.reviewProblemAddModeParams == null
            ? '복습할 문제 수정'
            : '복습할 문제 추가',
        onBackPressed: _onCancelButtonPressed,
        appBarActions: [
          if (widget.reviewProblemEditModeParams != null)
            AppBarAction(
              iconData: Icons.delete,
              tooltip: '삭제',
              onPressed: _onDeleteButtonPressed,
            ),
        ],
        bottomAction: PageLayoutBottomAction(
          label: widget.reviewProblemAddModeParams == null ? '수정' : '추가',
          onPressed: _onConfirmButtonPressed,
        ),
        child: _buildForm(),
      ),
    );
  }
}
