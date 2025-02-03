import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../../model/problem.dart';
import '../../common/review_problem_card.dart';
import 'edit_review_problem_dialog.dart';

class FormReviewProblemsField extends StatelessWidget {
  FormReviewProblemsField({
    super.key,
    required this.name,
    this.initialValue = const [],
  });

  final String name;
  final List<ReviewProblem> initialValue;

  final GlobalKey<FormFieldState<List<ReviewProblem>>> _fieldKey = GlobalKey();

  void _onReviewProblemCardTap(
    BuildContext context,
    ReviewProblem reviewProblem,
  ) {
    showDialog(
      context: context,
      routeSettings: const RouteSettings(name: 'review_problem_view_dialog'),
      builder: (context) {
        return EditReviewProblemDialog.edit(
          onReviewProblemEdit: _onReviewProblemEdit,
          onReviewProblemDelete: _onReviewProblemDelete,
          initialData: reviewProblem,
        );
      },
    );
  }

  void _onReviewProblemEdit(
    ReviewProblem oldReviewProblem,
    ReviewProblem newReviewProblem,
  ) {
    final field = _fieldKey.currentState;
    final newReviewProblems = [...?field?.value];
    final oldReviewProblemIndex = newReviewProblems.indexOf(oldReviewProblem);
    if (oldReviewProblemIndex == -1) return;

    newReviewProblems[oldReviewProblemIndex] = newReviewProblem;
    field?.didChange(newReviewProblems);
  }

  void _onReviewProblemDelete(ReviewProblem reviewProblem) {
    final field = _fieldKey.currentState;
    final newReviewProblems = [...?field?.value];
    newReviewProblems.remove(reviewProblem);
    field?.didChange(newReviewProblems);
  }

  void _onReviewProblemAddCardTap(BuildContext context) {
    showDialog(
      context: context,
      routeSettings: const RouteSettings(name: 'review_problem_add_dialog'),
      builder: (context) {
        return EditReviewProblemDialog.add(
          onReviewProblemAdd: _onReviewProblemAdd,
        );
      },
    );
  }

  void _onReviewProblemAdd(ReviewProblem reviewProblem) {
    final field = _fieldKey.currentState;
    field?.didChange([...?field.value, reviewProblem]);
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilderField<List<ReviewProblem>>(
      key: _fieldKey,
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
                onTap: () => _onReviewProblemCardTap(context, problem),
              ),
            _ReviewProblemAddCard(
              onTap: () => _onReviewProblemAddCardTap(context),
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
