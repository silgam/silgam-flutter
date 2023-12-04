import 'package:flutter/material.dart';

import '../cubit/onboarding_cubit.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView(
    this._cubit, {
    super.key,
  });

  final OnboardingCubit _cubit;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.orange,
      child: TextButton(
        child: const Text('다음'),
        onPressed: () {
          _cubit.next();
        },
      ),
    );
  }
}
