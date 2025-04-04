import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final bool isThin;
  final Clip clipBehavior;
  final double? width;

  const CustomCard({
    super.key,
    required this.child,
    this.backgroundColor = Colors.white,
    this.margin,
    this.padding,
    this.isThin = false,
    this.clipBehavior = Clip.hardEdge,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      clipBehavior: clipBehavior,
      margin: margin,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(isThin ? 100 : 14)),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(isThin ? 100 : 14),
        child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
      ),
    );
  }
}
