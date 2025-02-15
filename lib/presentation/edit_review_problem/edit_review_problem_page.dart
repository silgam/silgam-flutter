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

class EditReviewProblemPageArguments {
  final ReviewProblem? reviewProblemToEdit;

  EditReviewProblemPageArguments({this.reviewProblemToEdit});
}

sealed class EditReviewProblemPageResult {}

class EditReviewProblemPageSave extends EditReviewProblemPageResult {
  final ReviewProblem newReviewProblem;

  EditReviewProblemPageSave({required this.newReviewProblem});
}

class EditReviewProblemPageDelete extends EditReviewProblemPageResult {}

class EditReviewProblemPage extends StatefulWidget {
  const EditReviewProblemPage({
    super.key,
    this.reviewProblemToEdit,
  });

  final ReviewProblem? reviewProblemToEdit;

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

  late final String? _initialTitle = widget.reviewProblemToEdit?.title;
  late final String? _initialMemo = widget.reviewProblemToEdit?.memo;
  late final List<String> _initialImagePaths =
      widget.reviewProblemToEdit?.imagePaths ?? [];

  bool _isChanged = false;

  void _onBackPressed() {
    Navigator.maybePop(context);
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
                Navigator.pop(context);
                Navigator.pop(context, EditReviewProblemPageDelete());
              },
            ),
          ],
        );
      },
    );
  }

  void _onSaveButtonPressed() {
    final isFormValid = _formKey.currentState?.saveAndValidate() ?? false;
    if (!isFormValid) return;

    final Map<String, dynamic>? values = _formKey.currentState?.value;

    final newReviewProblem = ReviewProblem(
      title: values?[_titleFieldName],
      memo: values?[_memoFieldName] ?? '',
      imagePaths: values?[_imagePathsFieldName],
    );

    Navigator.pop(
      context,
      EditReviewProblemPageSave(newReviewProblem: newReviewProblem),
    );
  }

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

  Widget _buildImagesField() {
    return FormBuilderField(
      name: _imagePathsFieldName,
      initialValue: _initialImagePaths,
      builder: (field) {
        return GridView.extent(
          maxCrossAxisExtent: 280,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final String imagePath in field.value ?? [])
              Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  border: Border.all(width: 0.5, color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.white,
                ),
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
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Material(
                        color: Colors.white54,
                        clipBehavior: Clip.hardEdge,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: InkWell(
                          onTap: () => _onImageRemove(imagePath),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Icon(
                              Icons.clear,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
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
                child: Icon(
                  CupertinoIcons.add,
                  size: 24,
                  color: Colors.grey.shade600,
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
            description: '한 개의 복습할 문제에 여러 장의 사진을 추가할 수 있어요.',
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
        title: widget.reviewProblemToEdit == null ? '복습할 문제 추가' : '복습할 문제 수정',
        onBackPressed: _onBackPressed,
        appBarActions: [
          if (widget.reviewProblemToEdit != null)
            AppBarAction(
              iconData: Icons.delete,
              tooltip: '삭제',
              onPressed: _onDeleteButtonPressed,
            ),
        ],
        bottomAction: PageLayoutBottomAction(
          label: widget.reviewProblemToEdit == null ? '추가' : '수정',
          onPressed: _onSaveButtonPressed,
        ),
        child: _buildForm(),
      ),
    );
  }
}
