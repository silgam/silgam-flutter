import 'package:flutter/material.dart';

class FilterActionChip extends StatelessWidget {
  const FilterActionChip({
    super.key,
    required this.label,
    this.onPressed,
    this.tooltip,
  });

  final Widget label;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: label,
      onPressed: onPressed,
      tooltip: tooltip,
      pressElevation: 0,
      backgroundColor: Colors.grey.shade700.withAlpha(10),
      padding: EdgeInsets.zero,
      side: BorderSide(
        color: Colors.grey.shade700,
        width: 0.4,
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
