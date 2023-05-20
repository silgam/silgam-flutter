import '../model/dday.dart';
import '../presentation/home_page/main/main_view.dart';

class DDayUtil {
  DDayUtil(this._dDays);

  final List<DDay> _dDays;

  List<DDayItem> getItemsToShow(DateTime today) {
    today = DateTime(today.year, today.month, today.day);
    DDayItem? suneungDDay = _getSuneungDDay(today);
    DDayItem? mockTestDDay = _getMockTestDDay(today);
    return [
      if (suneungDDay != null) suneungDDay,
      if (mockTestDDay != null) mockTestDDay,
    ];
  }

  DDayItem? _getSuneungDDay(DateTime today) {
    final List<DDay> suneungs =
        _dDays.where((test) => test.testType == DDayType.suneung).toList();
    final DDay? previousSuneung = _getPreviousTest(today, suneungs);
    final DDay? nextSuneung = _getNextTest(today, suneungs);
    if (previousSuneung == null || nextSuneung == null) return null;

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
    final DDay? previousMockTest = _getPreviousTest(today, _dDays);
    final DDay? nextMockTest = _getNextTest(today, _dDays);
    if (previousMockTest == null ||
        nextMockTest == null ||
        nextMockTest.testType == DDayType.suneung) return null;

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

  DDay? _getPreviousTest(DateTime today, List<DDay> tests) {
    final previousTests = tests.where(
      (test) => test.date.add(const Duration(seconds: 1)).isBefore(today),
    );
    return previousTests.isEmpty ? null : previousTests.last;
  }

  DDay? _getNextTest(DateTime today, List<DDay> tests) {
    final nextTests = tests.where(
      (test) => test.date.add(const Duration(seconds: 1)).isAfter(today),
    );
    return nextTests.isEmpty ? null : nextTests.first;
  }
}
