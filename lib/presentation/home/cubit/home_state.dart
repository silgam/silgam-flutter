part of 'home_cubit.dart';

@freezed
class HomeState with _$HomeState {
  const factory HomeState({@Default(HomeCubit.defaultTabIndex) int tabIndex}) =
      _HomeState;
}
