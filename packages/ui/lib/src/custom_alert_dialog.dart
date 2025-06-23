import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  CustomAlertDialog({
    super.key,
    this.title,
    String? content,
    this.actions,
    this.scrollable = false,
    this.dimmedBackground = false,
  }) : content = content != null ? Text(content) : null;

  const CustomAlertDialog.customContent({
    super.key,
    this.title,
    this.content,
    this.actions,
    this.scrollable = false,
    this.dimmedBackground = false,
  });

  final String? title;
  final Widget? content;
  final List<Widget>? actions;
  final bool scrollable;
  final bool dimmedBackground;

  @override
  Widget build(BuildContext context) {
    final title = this.title;
    final content = this.content;

    return AlertDialog(
      title: title != null
          ? Text(title, style: const TextStyle(fontWeight: FontWeight.w700))
          : null,
      content: content,
      actions: actions,
      scrollable: scrollable,
      backgroundColor: dimmedBackground ? Theme.of(context).scaffoldBackgroundColor : null,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
