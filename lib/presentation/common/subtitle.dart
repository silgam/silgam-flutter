import 'package:flutter/material.dart';

class Subtitle extends StatelessWidget {
  const Subtitle({
    super.key,
    required this.text,
    this.margin = const EdgeInsets.symmetric(horizontal: 16),
  });

  final String text;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin,
      padding: const EdgeInsets.only(left: 8, right: 8, top: 12, bottom: 4),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
    );
  }
}
