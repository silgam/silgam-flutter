import 'package:flutter/material.dart';

class FormItem extends StatelessWidget {
  const FormItem({
    super.key,
    required this.label,
    required this.child,
    this.tooltip,
  });

  final String label;
  final Widget child;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FormLabel(label: label, tooltip: tooltip),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _FormLabel extends StatelessWidget {
  const _FormLabel({
    required this.label,
    this.tooltip,
  });

  final String label;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final labelWidget = Text(
      label,
      style: TextStyle(
        color: Colors.grey.shade900,
        fontWeight: FontWeight.w500,
      ),
    );

    if (tooltip == null) {
      return labelWidget;
    }

    return Row(
      children: [
        labelWidget,
        const SizedBox(width: 4),
        Tooltip(
          message: tooltip,
          triggerMode: TooltipTriggerMode.tap,
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          verticalOffset: 8,
          child: Icon(
            Icons.help_outline,
            color: Colors.grey.shade700,
            size: 16,
          ),
        ),
      ],
    );
  }
}
