import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHolder {
  static late final SharedPreferences _sharedPreferences;

  static SharedPreferences get get => _sharedPreferences;

  static Future<void> initializeSharedPreferences() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }
}

class PreferenceKey {
  static const showAddRecordPageAfterExamFinished = 'showAddRecordPageAfterExamFinished';
}
