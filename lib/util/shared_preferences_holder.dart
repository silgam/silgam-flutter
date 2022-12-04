import 'package:shared_preferences/shared_preferences.dart';

abstract class SharedPreferencesHolder {
  static late final SharedPreferences _sharedPreferences;

  static SharedPreferences get get => _sharedPreferences;

  static Future<void> initializeSharedPreferences() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }
}

abstract class PreferenceKey {
  static const showAddRecordPageAfterExamFinished =
      'showAddRecordPageAfterExamFinished';
  static const noisePreset = 'noisePreset';
  static const useWhiteNoise = 'whiteNoise';
}
