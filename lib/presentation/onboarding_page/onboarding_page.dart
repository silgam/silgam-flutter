import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../util/injection.dart';
import '../home_page/home_page.dart';
import 'cubit/onboarding_cubit.dart';
import 'join_path/join_path_view.dart';
import 'welcome/welcome_view.dart';

class OnboardingPage extends StatelessWidget {
  OnboardingPage({super.key});

  static const routeName = '/onboarding';
  final OnboardingCubit _cubit = getIt.get();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _cubit,
      child: BlocConsumer<OnboardingCubit, OnboardingState>(
        listener: (context, state) {
          if (state.step == OnboardingStep.finished) {
            Navigator.pushReplacementNamed(context, HomePage.routeName);
          }
        },
        buildWhen: (previous, current) =>
            current.step != OnboardingStep.finished,
        builder: (context, state) {
          switch (state.step) {
            case OnboardingStep.welcome:
              return WelcomeView(_cubit);
            case OnboardingStep.joinPath:
              return JoinPathView(_cubit);
            case OnboardingStep.finished:
              return Container();
          }
        },
      ),
    );
  }
}
