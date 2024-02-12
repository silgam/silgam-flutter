import 'package:flutter/material.dart';

import '../../model/exam.dart';
import '../../util/color_extension.dart';

class ExamFilterChip extends StatelessWidget {
  ExamFilterChip({
    super.key,
    required this.exam,
    required this.isSelected,
    required this.onSelected,
  }) : _darkColor = Color(exam.color).darken(0.1);

  final Exam exam;
  final bool isSelected;
  final Function() onSelected;
  final Color _darkColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        child: FilterChip(
          key: ValueKey('${exam.id} $isSelected'),
          label: Text(
            exam.name,
            style: TextStyle(
              color: isSelected ? Colors.white : _darkColor,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          onSelected: (_) => onSelected(),
          selected: false,
          side: BorderSide(
            color: _darkColor,
            width: 0.4,
          ),
          backgroundColor: Color(exam.color).withAlpha(isSelected ? 255 : 10),
          pressElevation: 0,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}
