import 'package:flutter/material.dart';

class ProgressOverlay extends StatelessWidget {
  final Widget child;
  final bool isProgressing;
  final String description;
  final bool fast;

  const ProgressOverlay({
    Key? key,
    required this.child,
    required this.isProgressing,
    required this.description,
    this.fast = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: fast ? const Duration(milliseconds: 100) : const Duration(seconds: 2),
            child: isProgressing
                ? Container(
                    padding: const EdgeInsets.all(8),
                    alignment: Alignment.center,
                    color: Colors.white.withAlpha(120),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(strokeWidth: 3),
                        const SizedBox(height: 20),
                        Text(
                          description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
