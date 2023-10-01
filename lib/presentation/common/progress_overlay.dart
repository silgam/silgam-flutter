import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

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
            duration: fast
                ? const Duration(milliseconds: 100)
                : const Duration(seconds: 2),
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

void initializeEasyLoading() {
  EasyLoading.instance
    ..maskType = EasyLoadingMaskType.custom
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorType = EasyLoadingIndicatorType.ring
    ..backgroundColor = Colors.transparent
    ..boxShadow = const []
    ..maskColor = Colors.black.withAlpha(60)
    ..backgroundColor = Colors.black.withAlpha(180)
    ..textStyle = const TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 15,
      color: Colors.white,
      height: 1.4,
    )
    ..textColor = Colors.white
    ..indicatorColor = Colors.white
    ..indicatorSize = 32
    ..lineWidth = 3;
}
