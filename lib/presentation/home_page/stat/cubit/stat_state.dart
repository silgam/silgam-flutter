part of 'stat_cubit.dart';

@freezed
class StatState with _$StatState {
  const factory StatState({
    @Default([]) List<ExamRecord> originalRecords,
    @Default(false) bool isLoading,
  }) = _StatState;
}
