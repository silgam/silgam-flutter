import 'package:flutter/material.dart';

import '../app/app.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final bool isThin;

  const CustomCard({
    Key? key,
    required this.child,
    this.backgroundColor = Colors.white,
    this.margin,
    this.padding,
    this.isThin = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isThin ? 100 : cardCornerRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            offset: const Offset(0, 2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Material(
        color: backgroundColor,
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}
