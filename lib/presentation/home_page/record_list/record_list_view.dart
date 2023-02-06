import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../model/exam_record.dart';
import '../../../model/subject.dart';
import '../../../util/injection.dart';
import '../../app/cubit/app_cubit.dart';
import '../../common/dialog.dart';
import '../../common/login_button.dart';
import '../../common/scaffold_body.dart';
import '../../common/subject_filter_chip.dart';
import '../../login_page/login_page.dart';
import '../../record_detail_page/record_detail_page.dart';
import '../cubit/home_cubit.dart';
import 'cubit/record_list_cubit.dart';
import 'record_tile.dart';

class RecordListView extends StatefulWidget {
  static const title = '기록';

  const RecordListView({
    Key? key,
  }) : super(key: key);

  @override
  State<RecordListView> createState() => _RecordListViewState();
}

class _RecordListViewState extends State<RecordListView> {
  final RecordListCubit _cubit = getIt.get();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _cubit,
      child: BlocListener<HomeCubit, HomeState>(
        listenWhen: (previous, current) =>
            previous.tabIndex != current.tabIndex,
        listener: (context, state) {
          if (state.tabIndex == 1) {
            _cubit.refresh();
          }
        },
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: BlocBuilder<AppCubit, AppState>(
            buildWhen: (previous, current) =>
                previous.isSignedIn != current.isSignedIn,
            builder: (_, appState) {
              return BlocBuilder<RecordListCubit, RecordListState>(
                builder: (_, state) {
                  return ScaffoldBody(
                    title: RecordListView.title,
                    isRefreshing: state.isLoading,
                    onRefresh: appState.isSignedIn ? _cubit.refresh : null,
                    slivers: [
                      _buildQuerySection(state),
                      if (appState.isNotSignedIn) _buildLoginButton(),
                      if (appState.isSignedIn)
                        _buildListSection(state.records, state.lockedRecordIds),
                      if (appState.isSignedIn && state.records.isEmpty)
                        _buildDescription(),
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
      child: Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        child: LoginButton(
          onTap: _onLoginTap,
          description: '로그인하면 모의고사를 기록할 수 있어요!',
        ),
      ),
    );
  }

  Widget _buildQuerySection(RecordListState state) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (value) => _cubit.onSearchTextChanged(value),
              cursorWidth: 1,
              cursorColor: Colors.grey.shade700,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                isCollapsed: true,
                filled: true,
                fillColor: Colors.grey.shade200,
                hintText: '제목, 피드백 검색',
                hintStyle: const TextStyle(fontWeight: FontWeight.w300),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const AlwaysScrollableScrollPhysics(),
            clipBehavior: Clip.none,
            child: IntrinsicHeight(
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  ActionChip(
                    label: Icon(Icons.replay,
                        size: 16, color: Colors.grey.shade700),
                    onPressed: _cubit.onFilterResetButtonTapped,
                    tooltip: '초기화',
                    pressElevation: 0,
                    backgroundColor: Colors.grey.shade700.withAlpha(10),
                    padding: EdgeInsets.zero,
                    side: BorderSide(color: Colors.grey.shade700, width: 0.4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const SizedBox(width: 6),
                  ActionChip(
                    label: Text(
                      state.sortType.name,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    onPressed: _cubit.onSortDateButtonTapped,
                    pressElevation: 0,
                    backgroundColor: Colors.grey.shade700.withAlpha(10),
                    side: BorderSide(color: Colors.grey.shade700, width: 0.4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const VerticalDivider(
                    indent: 6,
                    endIndent: 6,
                  ),
                  for (Subject subject in Subject.values)
                    SubjectFilterChip(
                      subject: subject,
                      isSelected: state.selectedSubjects.contains(subject),
                      onSelected: () =>
                          _cubit.onSubjectFilterButtonTapped(subject),
                    ),
                  const SizedBox(width: 13),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${state.records.length}개 / ${state.originalRecords.length}개',
                  style: const TextStyle(color: Colors.grey, height: 1.2),
                ),
                const SizedBox(width: 2),
                InkWell(
                  onTap: () => showExamRecordLimitInfoDialog(context),
                  borderRadius: BorderRadius.circular(100),
                  splashColor: Colors.transparent,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.help_outline,
                      size: 18,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection(
    List<ExamRecord> records,
    List<String> lockedRecordIds,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 12),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return RecordTile(
              record: records[index],
              onTileTap: () => _onTileTap(records[index]),
              isLocked: lockedRecordIds.contains(records[index].documentId),
            );
          },
          childCount: records.length,
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        child: const Text('오른쪽 아래 버튼을 눌러 모의고사를 기록해보세요!'),
      ),
    );
  }

  void _onLoginTap() async {
    await Navigator.pushNamed(context, LoginPage.routeName);
    await _cubit.refresh();
  }

  void _onTileTap(ExamRecord record) async {
    final args = RecordDetailPageArguments(record: record);
    await Navigator.pushNamed(context, RecordDetailPage.routeName,
        arguments: args);
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
