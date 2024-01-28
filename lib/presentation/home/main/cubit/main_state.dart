part of 'main_cubit.dart';

@freezed
class MainState with _$MainState {
  const factory MainState({
    @Default([]) List<Ads> ads,
    @Default([]) List<DDayItem> dDayItems,
  }) = _MainState;
}
