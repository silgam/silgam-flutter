class DDayRepository {
  DDayRepository._privateConstructor();

  static final _instance = DDayRepository._privateConstructor();

  factory DDayRepository() => _instance;

  final List<_Test> _tests = [
    _Test(
        testType: TestType.suneung,
        title: '대학수학능력시험',
        date: DateTime(2021, 11, 18)),
    _Test(
        testType: TestType.mockTest,
        title: '3월 학력평가',
        date: DateTime(2022, 3, 24)),
    _Test(
        testType: TestType.mockTest,
        title: '4월 학력평가',
        date: DateTime(2022, 4, 13)),
    _Test(
        testType: TestType.mockTest,
        title: '6월 모의평가',
        date: DateTime(2022, 6, 9)),
    _Test(
        testType: TestType.mockTest,
        title: '7월 학력평가',
        date: DateTime(2022, 7, 6)),
    _Test(
        testType: TestType.mockTest,
        title: '9월 모의평가',
        date: DateTime(2022, 8, 31)),
    _Test(
        testType: TestType.mockTest,
        title: '10월 학력평가',
        date: DateTime(2022, 10, 12)),
    _Test(
        testType: TestType.suneung,
        title: '대학수학능력시험',
        date: DateTime(2022, 11, 17)),
  ];

  List<DDayItem> getItemsToShow(DateTime today) {
    today = DateTime(today.year, today.month, today.day);
    DDayItem suneungDDay = _getSuneungDDay(today);
    DDayItem? mockTestDDay = _getMockTestDDay(today);
    return [
      suneungDDay,
      if (mockTestDDay != null) mockTestDDay,
    ];
  }

  DDayItem _getSuneungDDay(DateTime today) {
    final List<_Test> suneungs =
        _tests.where((test) => test.testType == TestType.suneung).toList();
    final _Test previousSuneung = _getPreviousTest(today, suneungs);
    final _Test nextSuneung = _getNextTest(today, suneungs);
    final remainingDays = nextSuneung.date.difference(today).inDays;
    final totalDays = nextSuneung.date.difference(previousSuneung.date).inDays;
    return DDayItem(
      title: nextSuneung.title,
      date: nextSuneung.date,
      remainingDays: remainingDays,
      progress: 1 - remainingDays / totalDays,
    );
  }

  DDayItem? _getMockTestDDay(DateTime today) {
    final _Test previousMockTest = _getPreviousTest(today, _tests);
    final _Test nextMockTest = _getNextTest(today, _tests);
    if (nextMockTest.testType == TestType.suneung) return null;
    final remainingDays = nextMockTest.date.difference(today).inDays;
    final totalDays =
        nextMockTest.date.difference(previousMockTest.date).inDays;
    return DDayItem(
      title: nextMockTest.title,
      date: nextMockTest.date,
      remainingDays: remainingDays,
      progress: 1 - remainingDays / totalDays,
    );
  }

  _Test _getPreviousTest(DateTime today, List<_Test> tests) {
    return tests.lastWhere(
        (test) => test.date.add(const Duration(seconds: 1)).isBefore(today));
  }

  _Test _getNextTest(DateTime today, List<_Test> tests) {
    return tests.firstWhere(
        (test) => test.date.add(const Duration(seconds: 1)).isAfter(today));
  }
}

class DDayItem {
  final String title;
  final DateTime date;
  final int remainingDays;
  final double progress;

  const DDayItem({
    required this.title,
    required this.date,
    required this.remainingDays,
    required this.progress,
  });
}

class _Test {
  final TestType testType;
  final String title;
  final DateTime date;

  const _Test({
    required this.testType,
    required this.title,
    required this.date,
  });

  @override
  String toString() {
    return '_Test{testType: $testType, title: $title, date: $date}';
  }
}

enum TestType {
  suneung,
  mockTest,
}
