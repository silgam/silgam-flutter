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

  Widget _buildLabel() {
    return Text(
      label,
      style: TextStyle(
        color: Colors.grey.shade500,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (tooltip == null) {
      return _buildLabel();
    }
    return Row(
      children: [
        _buildLabel(),
        const SizedBox(width: 4),
        Tooltip(
          message: tooltip,
          triggerMode: TooltipTriggerMode.tap,
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          verticalOffset: 8,
          child: Icon(
            Icons.help_outline,
            color: Colors.grey.shade500,
            size: 18,
          ),
        ),
      ],
    );
  }
}
