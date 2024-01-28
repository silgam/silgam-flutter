import 'package:flutter/material.dart';

import '../../model/subject.dart';
import '../../util/color_extension.dart';

class SubjectFilterChip extends StatelessWidget {
  SubjectFilterChip({
    super.key,
    required this.subject,
    required this.isSelected,
    required this.onSelected,
  }) : _darkColor = Color(subject.firstColor).darken(0.1);

  final Subject subject;
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
          key: ValueKey('$subject $isSelected'),
          label: Text(
            subject.subjectName,
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
          backgroundColor:
              Color(subject.firstColor).withAlpha(isSelected ? 255 : 10),
          pressElevation: 0,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}
