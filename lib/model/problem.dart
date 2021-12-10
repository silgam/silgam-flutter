class WrongProblem {
  final int problemNumber;

  WrongProblem(
    this.problemNumber,
  );
}

class ReviewProblem {
  final String title;
  final String? memo;
  final List<String> imagePaths;

  ReviewProblem({
    required this.title,
    this.memo,
    this.imagePaths = const [],
  });
}
