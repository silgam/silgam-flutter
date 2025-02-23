import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:ui/ui.dart';

import '../../model/subject.dart';
import '../../util/analytics_manager.dart';
import '../../util/injection.dart';
import '../app/cubit/app_cubit.dart';
import '../app/cubit/iap_cubit.dart';
import '../purchase/purchase_page.dart';
import 'cubit/customize_subject_name_cubit.dart';

class CustomizeSubjectNamePage extends StatefulWidget {
  const CustomizeSubjectNamePage({super.key});

  static const routeName = '/customize_subject_name';

  @override
  State<CustomizeSubjectNamePage> createState() =>
      _CustomizeSubjectNamePageState();
}

class _CustomizeSubjectNamePageState extends State<CustomizeSubjectNamePage> {
  final AppCubit _appCubit = getIt.get();
  final CustomizeSubjectNameCubit _cubit = getIt.get();

  final GlobalKey<FormBuilderState> _formKey = GlobalKey();
  late final Map<Subject, String> _initialSubjectNames =
      _appCubit.state.me?.customSubjectNameMap ?? defaultSubjectNameMap;

  void _onSavePressed() {
    if (!_appCubit.state.productBenefit.isCustomSubjectNameAvailable) {
      _showCustomSubjectNameNotAvailableDialog();
      return;
    }

    final isFormValid = _formKey.currentState?.saveAndValidate() ?? false;
    if (!isFormValid) return;

    final values = _formKey.currentState?.value;
    if (values == null) return;

    final Map<Subject, String> subjectNames = values.map(
      (subject, subjectName) => MapEntry(
        Subject.values.byName(subject),
        subjectName,
      ),
    );

    _cubit.save(subjectNames: subjectNames);
  }

  void _showCustomSubjectNameNotAvailableDialog() {
    showDialog(
      context: context,
      routeSettings: const RouteSettings(
        name:
            '${CustomizeSubjectNamePage.routeName}/custom_subject_name_not_available_dialog',
      ),
      builder: (context) {
        return BlocBuilder<IapCubit, IapState>(
          builder: (context, state) {
            final sellingProduct = state.sellingProduct;

            return CustomAlertDialog(
              title: '과목 이름 설정 기능 제한 안내',
              content: '과목 이름 설정 기능은 실감패스 사용자만 이용 가능해요.',
              actions: [
                CustomTextButton.secondary(
                  text: '확인',
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                if (sellingProduct != null)
                  CustomTextButton.primary(
                    text: '실감패스 확인하러 가기',
                    onPressed: () {
                      AnalyticsManager.logEvent(
                        name:
                            '[CustomizeSubjectNamePage] Check pass button tapped',
                      );
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed(
                        PurchasePage.routeName,
                        arguments: PurchasePageArguments(
                          product: sellingProduct,
                        ),
                      );
                    },
                  ),
              ],
            );
          },
        );
      },
    );
  }

  void _onSaved() {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('과목 이름이 저장되었습니다.'),
      ),
    );
  }

  void _onPopInvokedWithResult(bool didPop, _) {
    if (didPop) return;

    showDialog(
      context: context,
      routeSettings: const RouteSettings(
        name: '${CustomizeSubjectNamePage.routeName}/exit_confirm_dialog',
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

  Widget _buildForm(CustomizeSubjectNameState state) {
    return FormBuilder(
      key: _formKey,
      enabled: state.status != CustomizeSubjectNameStatus.saving,
      canPop: !state.isFormChanged &&
          state.status != CustomizeSubjectNameStatus.saving,
      onPopInvokedWithResult: _onPopInvokedWithResult,
      onChanged: _cubit.onFormChanged,
      child: Column(
        spacing: 20,
        children: [
          for (final subject in Subject.values)
            FormItem(
              label: subject.defaultName,
              child: FormTextField(
                name: subject.name,
                initialValue: _initialSubjectNames[subject],
                textInputAction: TextInputAction.next,
                validator: FormBuilderValidators.maxLength(
                  10,
                  errorText: '10자 이하로 입력해주세요.',
                  checkNullOrEmpty: false,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _cubit,
      child: BlocConsumer<CustomizeSubjectNameCubit, CustomizeSubjectNameState>(
        listener: (context, state) {
          if (state.status == CustomizeSubjectNameStatus.saved) {
            _onSaved();
          }
        },
        builder: (context, state) {
          return PageLayout(
            title: '기본 과목 이름 설정',
            onBackPressed: () => Navigator.of(context).maybePop(),
            bottomAction: PageLayoutBottomAction(
              label: '저장',
              onPressed: _onSavePressed,
            ),
            isBottomActionLoading:
                state.status == CustomizeSubjectNameStatus.saving,
            unfocusOnTapBackground: true,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildForm(state),
            ),
          );
        },
      ),
    );
  }
}
