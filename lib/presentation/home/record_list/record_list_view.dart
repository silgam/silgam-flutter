import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../model/exam.dart';
import '../../../model/exam_record.dart';
import '../../../util/injection.dart';
import '../../app/cubit/app_cubit.dart';
import '../../common/dialog.dart';
import '../../common/filter_action_chip.dart';
import '../../common/login_button.dart';
import '../../common/scaffold_body.dart';
import '../../common/search_field.dart';
import '../../common/subject_filter_chip.dart';
import '../../login/login_page.dart';
import '../../record_detail/record_detail_page.dart';
import '../cubit/home_cubit.dart';
import '../home_page.dart';
import 'cubit/record_list_cubit.dart';
import 'record_tile.dart';

class RecordListView extends StatefulWidget {
  static const title = '기록';

  const RecordListView({super.key});

  @override
  State<RecordListView> createState() => _RecordListViewState();
}

class _RecordListViewState extends State<RecordListView> {
  final RecordListCubit _cubit = getIt.get();

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: MultiBlocListener(
        listeners: [
          BlocListener<HomeCubit, HomeState>(
            listenWhen: (previous, current) => previous.tabIndex != current.tabIndex,
            listener: (context, state) {
              final recordListTabIndex = HomePage.views.keys.toList().indexOf(RecordListView.title);
              if (state.tabIndex == recordListTabIndex) {
                _cubit.refresh();
              }
            },
          ),
          BlocListener<AppCubit, AppState>(
            listenWhen: (previous, current) =>
                previous.me != current.me ||
                previous.productBenefit != current.productBenefit ||
                previous.isOffline != current.isOffline,
            listener: (context, state) {
              _cubit.refresh();
            },
          ),
        ],
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: BlocBuilder<AppCubit, AppState>(
            builder: (_, appState) {
              return BlocBuilder<RecordListCubit, RecordListState>(
                builder: (_, state) {
                  return ScaffoldBody(
                    title: RecordListView.title,
                    isRefreshing: state.isLoading,
                    onRefresh: appState.isSignedIn ? _cubit.refresh : null,
                    slivers: [
                      _buildQuerySection(state, appState),
                      if (appState.isNotSignedIn) _buildLoginButton(),
                      if (appState.isSignedIn) _buildListSection(state.records),
                      if (appState.isSignedIn && state.records.isEmpty) _buildDescription(),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Align(
        alignment: Alignment.center,
        child: LoginButton(onTap: _onLoginTap, description: '로그인하면 모의고사를 기록할 수 있어요!'),
      ),
    );
  }

  Widget _buildQuerySection(RecordListState state, AppState appState) {
    final List<Exam> allExams = appState.getAllExams();
    if (!allExams.map((e) => e.id).toSet().containsAll(state.selectedExamIds)) {
      _cubit.onFilterResetButtonTapped();
    }

    final examRecordLimit = appState.productBenefit.examRecordLimit;

    return NonPaddingChildBuilder(
      builder: (horizontalPadding) {
        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: SearchField(
                  onChanged: (value) => _cubit.onSearchTextChanged(value),
                  hintText: '제목, 피드백 검색',
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      SizedBox(width: horizontalPadding),
                      FilterActionChip(
                        label: Icon(Icons.replay, size: 16, color: Colors.grey.shade700),
                        onPressed: _cubit.onFilterResetButtonTapped,
                        tooltip: '초기화',
                      ),
                      const SizedBox(width: 6),
                      FilterActionChip(
                        label: Text(
                          state.sortType.name,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        onPressed: _cubit.onSortDateButtonTapped,
                        tooltip: '정렬',
                      ),
                      const VerticalDivider(indent: 6, endIndent: 6),
                      for (Exam exam in allExams.where((exam) => exam.name.isNotEmpty))
                        ExamFilterChip(
                          exam: exam,
                          isSelected: state.selectedExamIds.contains(exam.id),
                          onSelected: () => _cubit.onExamFilterButtonTapped(exam),
                        ),
                      SizedBox(width: horizontalPadding),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: horizontalPadding),
                  Text(
                    '${state.records.length}개${examRecordLimit == -1 ? '' : ' (최대 $examRecordLimit개)'}',
                    style: const TextStyle(color: Colors.grey, height: 1.2),
                  ),
                  const SizedBox(width: 2),
                  if (examRecordLimit != -1)
                    InkWell(
                      onTap: () => showExamRecordLimitInfoDialog(context),
                      borderRadius: BorderRadius.circular(100),
                      splashColor: Colors.transparent,
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.help_outline, size: 18, color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListSection(List<ExamRecord> records) {
    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 12),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return RecordTile(record: records[index], onTileTap: () => _onTileTap(records[index]));
        }, childCount: records.length),
      ),
    );
  }

  Widget _buildDescription() {
    return const SliverFillRemaining(
      hasScrollBody: false,
      child: Align(
        alignment: Alignment.center,
        child: Text('오른쪽 아래 버튼을 눌러 모의고사를 기록해보세요!', textAlign: TextAlign.center),
      ),
    );
  }

  void _onLoginTap() {
    Navigator.pushNamed(context, LoginPage.routeName);
  }

  void _onTileTap(ExamRecord record) {
    Navigator.pushNamed(
      context,
      RecordDetailPage.routeName,
      arguments: RecordDetailPageArguments(recordId: record.id),
    );
  }
}

enum RecordSortType {
  dateDesc('최신순'),
  dateAsc('오래된순'),
  titleAsc('이름 오름차순'),
  titleDesc('이름 내림차순');

  final String name;

  const RecordSortType(this.name);
}
