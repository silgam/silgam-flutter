import 'package:flutter/material.dart';
import 'package:silgam/model/problem.dart';

class ReviewProblemDetailPage extends StatelessWidget {
  static const routeName = '/review_problem_detail';
  final ReviewProblem reviewProblem;

  const ReviewProblemDetailPage({
    Key? key,
    required this.reviewProblem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class ReviewProblemDetailPageArguments {
  ReviewProblem problem;

  ReviewProblemDetailPageArguments({
    required this.problem,
  });
}
