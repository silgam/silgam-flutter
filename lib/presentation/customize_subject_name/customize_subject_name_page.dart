import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/subject.dart';
import '../../util/injection.dart';
import '../app/cubit/app_cubit.dart';
import '../common/custom_menu_bar.dart';
import '../common/free_user_block_overlay.dart';
import 'cubit/customize_subject_name_cubit.dart';

class CustomizeSubjectNamePage extends StatelessWidget {
  CustomizeSubjectNamePage({super.key});

  static const routeName = '/customize_subject_name';
  final CustomizeSubjectNameCubit _cubit = getIt.get();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _cubit,
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                const CustomMenuBar(title: '기본 과목 이름 설정'),
                Expanded(
                  child: Stack(
                    children: [
                      _buildBody(),
                      _buildOverlay(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return BlocConsumer<CustomizeSubjectNameCubit, CustomizeSubjectNameState>(
      listener: (context, state) {
        if (state.isSaved) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('과목 이름이 저장되었습니다.'),
            ),
          );
        }
      },
      builder: (context, state) {
        final textControllerMap = state.subjectNameMap.map(
          (subject, subjectName) => MapEntry(
            subject,
            TextEditingController(text: subjectName),
          ),
        );

        return Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                itemCount: Subject.values.length,
                itemBuilder: (context, index) {
                  final subject = Subject.values[index];
                  return TextField(
                    controller: textControllerMap[subject],
                    maxLength: 10,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey.shade400,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey.shade400,
                        ),
                      ),
                      hintText: '과목 이름을 입력하세요',
                      labelText: subject.defaultName,
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 8);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Material(
                color: Theme.of(context).primaryColor,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();

                    final subjectNameMap = textControllerMap.map(
                      (subject, textController) => MapEntry(
                        subject,
                        textController.text,
                      ),
                    );
                    _cubit.onSaveButtonPressed(subjectNameMap);
                  },
                  splashColor: Colors.transparent,
                  highlightColor: Colors.grey.withAlpha(60),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    child: const Text(
                      '저장하기',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  Widget _buildOverlay() {
    return BlocBuilder<AppCubit, AppState>(
      buildWhen: (previous, current) =>
          previous.productBenefit.isCustomSubjectNameAvailable !=
          current.productBenefit.isCustomSubjectNameAvailable,
      builder: (context, state) {
        if (state.productBenefit.isCustomSubjectNameAvailable) {
          return const SizedBox.shrink();
        }
        return const FreeUserBlockOverlay(
          text: '과목 이름 설정 기능은 실감패스 사용자만 이용 가능해요.',
        );
      },
    );
  }
}
