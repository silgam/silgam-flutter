import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../util/injection.dart';
import '../../app/cubit/app_cubit.dart';
import '../../common/login_button.dart';
import '../../common/scaffold_body.dart';
import '../../login_page/login_page.dart';
import '../record_list/cubit/record_list_cubit.dart';
import 'cubit/stat_cubit.dart';

class StatView extends StatefulWidget {
  const StatView({super.key});

  static const title = '통계';

  @override
  State<StatView> createState() => _StatViewState();
}

class _StatViewState extends State<StatView> {
  final StatCubit _cubit = getIt.get();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _cubit,
      child: BlocListener<RecordListCubit, RecordListState>(
        bloc: getIt.get(),
        listenWhen: (previous, current) =>
            previous.originalRecords != current.originalRecords,
        listener: (_, recordListState) =>
            _cubit.onOriginalRecordsUpdated(recordListState.originalRecords),
        child: BlocBuilder<AppCubit, AppState>(
          buildWhen: (previous, current) =>
              previous.isSignedIn != current.isSignedIn,
          builder: (context, appState) {
            return BlocBuilder<StatCubit, StatState>(
              builder: (context, state) {
                return ScaffoldBody(
                  title: StatView.title,
                  isRefreshing: state.isLoading,
                  onRefresh: appState.isSignedIn ? _cubit.refresh : null,
                  slivers: [
                    if (appState.isNotSignedIn) _buildLoginButton(),
                  ],
                );
              },
            );
          },
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
          description: '로그인하면 통계를 볼 수 있어요!',
        ),
      ),
    );
  }

  void _onLoginTap() {
    Navigator.pushNamed(context, LoginPage.routeName);
  }
}
