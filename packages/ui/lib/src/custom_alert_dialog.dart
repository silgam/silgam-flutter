import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  const CustomAlertDialog({
    super.key,
    this.title,
    this.content,
    this.actions = const [],
    this.scrollable = false,
  });

  final String? title;
  final String? content;
  final List<Action> actions;
  final bool scrollable;

  Widget _buildAction(Action action) {
    return switch (action) {
      PrimaryAction() => TextButton(
          onPressed: action.onPressed,
          child: Text(action.text),
        ),
      SecondaryAction() => TextButton(
          onPressed: action.onPressed,
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey.shade600,
          ),
          child: Text(action.text),
        ),
      DestructiveAction() => TextButton(
          onPressed: action.onPressed,
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
          ),
          child: Text(action.text),
        ),
    };
  }

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
      actions: actions.isNotEmpty ? actions.map(_buildAction).toList() : null,
      scrollable: scrollable,
    );
  }
}

sealed class Action {
  const Action({
    required this.text,
    this.onPressed,
  });

  final String text;
  final VoidCallback? onPressed;
}

class PrimaryAction extends Action {
  const PrimaryAction({
    required super.text,
    super.onPressed,
  });
}

class SecondaryAction extends Action {
  const SecondaryAction({
    required super.text,
    super.onPressed,
  });
}

class DestructiveAction extends Action {
  const DestructiveAction({
    required super.text,
    super.onPressed,
  });
}
