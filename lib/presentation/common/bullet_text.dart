import 'package:flutter/material.dart';

class BulletText extends StatelessWidget {
  const BulletText({super.key, required this.text, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '• ',
          style:
              style?.copyWith(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w300,
              ) ??
              const TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w300,
                color: Colors.grey,
                height: 1.2,
              ),
        ),
        Flexible(child: Text(text, textAlign: TextAlign.start, style: style)),
      ],
    );
  }
}
