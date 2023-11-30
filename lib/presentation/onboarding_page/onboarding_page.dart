import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../util/injection.dart';
import 'cubit/onboarding_cubit.dart';

class OnboardingPage extends StatelessWidget {
  OnboardingPage({super.key});

  static const routeName = '/onboarding';
  final OnboardingCubit _cubit = getIt.get();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _cubit,
      child: BlocBuilder<OnboardingCubit, OnboardingState>(
        builder: (context, state) {
          return Container();
        },
      ),
    );
  }
}
