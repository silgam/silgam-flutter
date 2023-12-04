import 'package:flutter/material.dart';

import '../cubit/onboarding_cubit.dart';

class JoinPathView extends StatelessWidget {
  const JoinPathView(
    this._cubit, {
    super.key,
  });

  final OnboardingCubit _cubit;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      child: Center(
        child: TextButton(
          child: const Text('다음'),
          onPressed: () {
            _cubit.next();
          },
        ),
      ),
    );
  }
}
