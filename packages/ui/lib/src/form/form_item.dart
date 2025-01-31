import 'package:flutter/material.dart';

class FormItem extends StatelessWidget {
  const FormItem({
    super.key,
    required this.label,
    required this.child,
    this.isRequired = false,
    this.tooltip,
  });

  final String label;
  final Widget child;
  final bool isRequired;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FormLabel(
          label: label,
          isRequired: isRequired,
          tooltip: tooltip,
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _FormLabel extends StatelessWidget {
  const _FormLabel({
    required this.label,
    this.isRequired = false,
    this.tooltip,
  });

  final String label;
  final bool isRequired;
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

    if (tooltip == null && !isRequired) {
      return labelWidget;
    }

    return Row(
      spacing: 4,
      children: [
        labelWidget,
        if (isRequired)
          const Text(
            '*',
            style: TextStyle(color: Colors.red),
          ),
        if (tooltip != null)
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
