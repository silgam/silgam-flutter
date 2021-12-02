import 'package:flutter/material.dart';

class UiVisibility extends StatelessWidget {
  final Widget child;
  final bool uiVisible;

  const UiVisibility({
    Key? key,
    required this.child,
    required this.uiVisible,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: !uiVisible,
      child: AnimatedOpacity(
        opacity: uiVisible ? 1 : 0,
        duration: const Duration(milliseconds: 100),
        child: child,
      ),
    );
  }
}
