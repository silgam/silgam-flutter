import 'package:flutter/material.dart';

class MaterialHero extends StatelessWidget {
  final String tag;
  final Widget child;

  const MaterialHero({
    Key? key,
    required this.tag,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: Material(
        type: MaterialType.transparency,
        child: child,
      ),
    );
  }
}
