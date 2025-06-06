import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../../model/problem.dart';
import '../../common/review_problem_card.dart';
import '../../edit_review_problem/edit_review_problem_page.dart';

class FormReviewProblemsField extends StatefulWidget {
  const FormReviewProblemsField({super.key, required this.name, this.initialValue = const []});

  final String name;
  final List<ReviewProblem> initialValue;

  @override
  State<FormReviewProblemsField> createState() => _FormReviewProblemsFieldState();
}

class _FormReviewProblemsFieldState extends State<FormReviewProblemsField> {
  final GlobalKey<FormFieldState<List<ReviewProblem>>> _fieldKey = GlobalKey();

  Future<void> _onReviewProblemCardTap(BuildContext context, ReviewProblem reviewProblem) async {
    final result = await Navigator.pushNamed<EditReviewProblemPageResult>(
      context,
      EditReviewProblemPage.routeName,
      arguments: EditReviewProblemPageArguments(reviewProblemToEdit: reviewProblem),
    );

    switch (result) {
      case EditReviewProblemPageSave():
        _editReviewProblem(
          oldReviewProblem: reviewProblem,
          newReviewProblem: result.newReviewProblem,
        );
        break;
      case EditReviewProblemPageDelete():
        _deleteReviewProblem(reviewProblem);
        break;
      case null:
        break;
    }
  }

  Future<void> _onReviewProblemAddCardTap(BuildContext context) async {
    final result = await Navigator.pushNamed<EditReviewProblemPageResult>(
      context,
      EditReviewProblemPage.routeName,
    );

    switch (result) {
      case EditReviewProblemPageSave():
        _addReviewProblem(result.newReviewProblem);
        break;
      case EditReviewProblemPageDelete():
      case null:
        break;
    }
  }

  void _editReviewProblem({
    required ReviewProblem oldReviewProblem,
    required ReviewProblem newReviewProblem,
  }) {
    final field = _fieldKey.currentState;
    final newReviewProblems = [...?field?.value];
    final oldReviewProblemIndex = newReviewProblems.indexOf(oldReviewProblem);
    if (oldReviewProblemIndex == -1) return;

    newReviewProblems[oldReviewProblemIndex] = newReviewProblem;
    field?.didChange(newReviewProblems);
  }

  void _deleteReviewProblem(ReviewProblem reviewProblem) {
    final field = _fieldKey.currentState;
    final newReviewProblems = [...?field?.value];
    newReviewProblems.remove(reviewProblem);
    field?.didChange(newReviewProblems);
  }

  void _addReviewProblem(ReviewProblem reviewProblem) {
    final field = _fieldKey.currentState;
    field?.didChange([...?field.value, reviewProblem]);
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilderField<List<ReviewProblem>>(
      key: _fieldKey,
      name: widget.name,
      initialValue: widget.initialValue,
      builder: (field) {
        final state =
            field
                as FormBuilderFieldState<
                  FormBuilderField<List<ReviewProblem>>,
                  List<ReviewProblem>
                >;

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
                onTap: state.enabled ? () => _onReviewProblemCardTap(context, problem) : null,
              ),
            _ReviewProblemAddCard(
              onTap: state.enabled ? () => _onReviewProblemAddCardTap(context) : null,
            ),
          ],
        );
      },
    );
  }
}

class _ReviewProblemAddCard extends StatelessWidget {
  const _ReviewProblemAddCard({required this.onTap});

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
            Icon(CupertinoIcons.add, size: 24, color: Colors.grey.shade600),
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
