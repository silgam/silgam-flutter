import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../util/injection.dart';
import 'cubit/exam_overview_cubit.dart';

class ExamOverviewPage extends StatefulWidget {
  const ExamOverviewPage({super.key});

  static const routeName = '/exam_overview';

  @override
  State<ExamOverviewPage> createState() => _ExamOverviewPageState();
}

class _ExamOverviewPageState extends State<ExamOverviewPage> {
  final ExamOverviewCubit _cubit = getIt.get();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _cubit,
      child: Scaffold(
        body: SafeArea(
          child: Container(),
        ),
      ),
    );
  }
}

class ExamOverviewPageArguments {}
