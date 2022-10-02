import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../model/exam_record.dart';
import '../../common/login_button.dart';
import '../../common/scaffold_body.dart';
import '../../login_page/login_page.dart';
import '../../record_detail_page/record_detail_page.dart';
import 'cubit/record_list_cubit.dart';
import 'record_tile.dart';

class RecordListView extends StatefulWidget {
  static const title = '기록';
  final Stream<RecordListViewEvent> eventStream;

  const RecordListView({
    Key? key,
    required this.eventStream,
  }) : super(key: key);

  @override
  State<RecordListView> createState() => _RecordListViewState();
}

class _RecordListViewState extends State<RecordListView> {
  late final StreamSubscription _eventStreamSubscription;
  final RecordListCubit cubit = RecordListCubit();

  @override
  void initState() {
    super.initState();
    _eventStreamSubscription = widget.eventStream.listen(_onEventReceived);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => cubit,
      child: BlocBuilder<RecordListCubit, RecordListState>(
        builder: (context, state) {
          return ScaffoldBody(
            title: RecordListView.title,
            isRefreshing: state is RecordListLoading,
            onRefresh: state is RecordListNotSignedIn ? null : cubit.refresh,
            slivers: [
              _buildQuerySection(),
              if (state is RecordListNotSignedIn) _buildLoginButton(),
              if (state is RecordListLoaded) _buildListSection(state.records),
              if (state is RecordListLoading) _buildListSection(state.records),
              if (state is RecordListLoaded && state.records.isEmpty) _buildDescription(),
              if (state is RecordListLoading && state.records.isEmpty) _buildDescription(),
            ],
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

  Widget _buildQuerySection() {
    return SliverToBoxAdapter(
      child: Container(
        height: 100,
        color: Colors.red,
      ),
    );
  }

  Widget _buildListSection(List<ExamRecord> records) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(vertical: 12),
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
        cubit.refresh();
        break;
      case RecordListViewEvent.refreshUser:
        cubit.refresh();
        break;
    }
  }

  void _onLoginTap() async {
    await Navigator.pushNamed(context, LoginPage.routeName);
    await cubit.refresh();
  }

  void _onTileTap(ExamRecord record) async {
    final args = RecordDetailPageArguments(record: record);
    await Navigator.pushNamed(context, RecordDetailPage.routeName, arguments: args);
    await cubit.refresh();
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
