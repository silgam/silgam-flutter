import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../model/exam_record.dart';
import '../../../model/subject.dart';
import '../../../util/injection.dart';
import '../../common/login_button.dart';
import '../../common/scaffold_body.dart';
import '../../login_page/login_page.dart';
import '../../record_detail_page/record_detail_page.dart';
import '../home_page.dart';
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
  late final StreamSubscription _eventStreamSubscription;
  final RecordListCubit _cubit = getIt.get();

  @override
  void initState() {
    super.initState();
    _eventStreamSubscription = HomePage
        .recordListViewEventStreamController.stream
        .listen(_onEventReceived);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _cubit,
      child: BlocBuilder<RecordListCubit, RecordListState>(
        builder: (context, state) {
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: ScaffoldBody(
              title: RecordListView.title,
              isRefreshing: state.isLoading,
              onRefresh: state.isSignedIn ? _cubit.refresh : null,
              slivers: [
                _buildQuerySection(state),
                if (state.isNotSignedIn) _buildLoginButton(),
                if (state.isSignedIn) _buildListSection(state.records),
                if (state.isSignedIn && state.records.isEmpty)
                  _buildDescription(),
              ],
            ),
          );
        },
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
                    _buildSubjectFilterChip(state, subject),
                  const SizedBox(width: 13),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${state.records.length}개 / ${state.originalRecords.length}개',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildSubjectFilterChip(RecordListState state, Subject subject) {
    final bool selected = state.selectedSubjects.contains(subject);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: AnimatedSwitcher(
        duration: const Duration(seconds: 1),
        child: FilterChip(
          label: Text(
            subject.subjectName,
            style: TextStyle(
              color: selected ? Colors.white : Color(subject.secondColor),
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          onSelected: (value) => _cubit.onSubjectFilterButtonTapped(subject),
          selected: false,
          side: BorderSide(
            color: Color(subject.secondColor),
            width: 0.4,
          ),
          backgroundColor:
              Color(subject.firstColor).withAlpha(selected ? 255 : 10),
          pressElevation: 0,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }

  Widget _buildListSection(List<ExamRecord> records) {
    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 12),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return RecordTile(
              record: records[index],
              onTileTap: () => _onTileTap(records[index]),
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

  void _onEventReceived(RecordListViewEvent event) {
    switch (event) {
      case RecordListViewEvent.refresh:
        _cubit.refresh();
        break;
      case RecordListViewEvent.refreshUser:
        _cubit.refresh();
        break;
    }
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

  @override
  void dispose() {
    _eventStreamSubscription.cancel();
    super.dispose();
  }
}

enum RecordListViewEvent {
  refresh,
  refreshUser,
}

enum RecordSortType {
  dateDesc('최신순'),
  dateAsc('오래된순'),
  titleAsc('이름 오름차순'),
  titleDesc('이름 내림차순');

  final String name;

  const RecordSortType(this.name);
}
