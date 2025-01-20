import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  const CustomAlertDialog({
    super.key,
    this.title,
    this.content,
    this.actions,
    this.scrollable = false,
  });

  final String? title;
  final String? content;
  final List<Widget>? actions;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final title = this.title;
    final content = this.content;

    return AlertDialog(
      title: title != null
          ? Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w700),
            )
          : null,
      content: content != null ? Text(content) : null,
      actions: actions,
      scrollable: scrollable,
    );
  }
}
