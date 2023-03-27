import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/subject.dart';
import '../app/cubit/app_cubit.dart';
import '../common/custom_menu_bar.dart';

class CustomizeSubjectNamePage extends StatelessWidget {
  const CustomizeSubjectNamePage({super.key});

  static const routeName = '/customize_subject_name';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<AppCubit, AppState>(
            builder: (context, appState) {
              return Column(
                children: [
                  const CustomMenuBar(title: '과목 이름 설정'),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      itemCount: Subject.defaultSubjectNameMap.length,
                      itemBuilder: (context, index) {
                        final subject =
                            Subject.defaultSubjectNameMap.keys.elementAt(index);
                        return TextField(
                          controller: TextEditingController(
                            text: subject.subjectName,
                          ),
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
                            labelText: Subject.defaultSubjectNameMap[subject],
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
                        onTap: () {},
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
          ),
        ),
      ),
    );
  }
}
