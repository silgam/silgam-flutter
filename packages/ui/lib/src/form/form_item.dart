import 'package:flutter/material.dart';

class FormItem extends StatelessWidget {
  const FormItem({
    super.key,
    required this.label,
    required this.child,
    this.isRequired = false,
    this.description,
  });

  final String label;
  final Widget child;
  final bool isRequired;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final description = this.description;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        _FormLabel(label: label, isRequired: isRequired),
        if (description != null)
          Text(description, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        child,
      ],
    );
  }
}

class _FormLabel extends StatelessWidget {
  const _FormLabel({required this.label, this.isRequired = false});

  final String label;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    final labelWidget = Text(
      label,
      style: TextStyle(color: Colors.grey.shade900, fontWeight: FontWeight.w500, fontSize: 15),
    );

    if (isRequired) {
      return Row(
        spacing: 2,
        children: [
          labelWidget,
          const Text('*', style: TextStyle(color: Colors.red)),
        ],
      );
    }

    return labelWidget;
  }
}
