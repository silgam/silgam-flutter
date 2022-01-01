import 'package:flutter/material.dart';

class ProgressOverlay extends StatelessWidget {
  final Widget child;
  final bool isProgressing;
  final String description;

  const ProgressOverlay({
    Key? key,
    required this.child,
    required this.isProgressing,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: AnimatedOpacity(
            duration: const Duration(seconds: 2),
            opacity: isProgressing ? 1 : 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              alignment: Alignment.center,
              color: isProgressing ? Colors.white.withAlpha(120) : null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(strokeWidth: 3),
                  const SizedBox(height: 20),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
