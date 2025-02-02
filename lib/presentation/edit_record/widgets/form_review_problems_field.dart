import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../../model/problem.dart';
import '../../common/review_problem_card.dart';
import '../edit_review_problem_dialog.dart';

typedef _FormFieldState = FormFieldState<List<ReviewProblem>>;

class FormReviewProblemsField extends StatelessWidget {
  const FormReviewProblemsField({
    super.key,
    required this.name,
    this.initialValue = const [],
  });

  final String name;
  final List<ReviewProblem> initialValue;

  void _onReviewProblemCardTap(
    BuildContext context,
    _FormFieldState field,
    ReviewProblem reviewProblem,
  ) {
    showDialog(
      context: context,
      routeSettings: const RouteSettings(name: 'review_problem_view_dialog'),
      builder: (context) {
        return EditReviewProblemDialog.edit(
          onReviewProblemEdit: (oldReviewProblem, newReviewProblem) =>
              _onReviewProblemEdit(field, oldReviewProblem, newReviewProblem),
          onReviewProblemDelete: (reviewProblem) =>
              _onReviewProblemDelete(field, reviewProblem),
          initialData: reviewProblem,
        );
      },
    );
  }

  void _onReviewProblemEdit(
    _FormFieldState field,
    ReviewProblem oldReviewProblem,
    ReviewProblem newReviewProblem,
  ) {
    final newReviewProblems = [...?field.value];
    final oldReviewProblemIndex = newReviewProblems.indexOf(oldReviewProblem);
    if (oldReviewProblemIndex == -1) return;

    newReviewProblems[oldReviewProblemIndex] = newReviewProblem;
    field.didChange(newReviewProblems);
  }

  void _onReviewProblemDelete(
    _FormFieldState field,
    ReviewProblem reviewProblem,
  ) {
    final newReviewProblems = [...?field.value];
    newReviewProblems.remove(reviewProblem);
    field.didChange(newReviewProblems);
  }

  void _onReviewProblemAddCardTap(BuildContext context, _FormFieldState field) {
    showDialog(
      context: context,
      routeSettings: const RouteSettings(name: 'review_problem_add_dialog'),
      builder: (context) {
        return EditReviewProblemDialog.add(
          onReviewProblemAdd: (reviewProblem) =>
              _onReviewProblemAdd(field, reviewProblem),
        );
      },
    );
  }

  void _onReviewProblemAdd(_FormFieldState field, ReviewProblem reviewProblem) {
    field.didChange([...?field.value, reviewProblem]);
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilderField<List<ReviewProblem>>(
      name: name,
      initialValue: initialValue,
      builder: (field) {
        return GridView.extent(
          maxCrossAxisExtent: 400,
          childAspectRatio: 1.5,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final problem in field.value ?? [])
              ReviewProblemCard(
                problem: problem,
                onTap: () => _onReviewProblemCardTap(context, field, problem),
              ),
            _ReviewProblemAddCard(
              onTap: () => _onReviewProblemAddCardTap(context, field),
            ),
          ],
        );
      },
    );
  }
}

class _ReviewProblemAddCard extends StatelessWidget {
  const _ReviewProblemAddCard({
    required this.onTap,
  });

  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        splashFactory: NoSplash.splashFactory,
        child: Row(
          spacing: 4,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.add,
              size: 24,
              color: Colors.grey.shade600,
            ),
            Text(
              '추가하기',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
