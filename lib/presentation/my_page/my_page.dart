import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../model/user.dart';
import '../app/cubit/app_cubit.dart';
import '../common/custom_menu_bar.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  static const routeName = '/my_page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const CustomMenuBar(
              title: '마이페이지',
            ),
            Expanded(
              child: BlocBuilder<AppCubit, AppState>(
                buildWhen: (previous, current) => previous.me != current.me,
                builder: (context, state) {
                  final me = state.me;
                  if (me == null) {
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 3),
                    );
                  }
                  return ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: HSLColor.fromColor(
                                      Theme.of(context).primaryColor)
                                  .withLightness(0.3)
                                  .toColor(),
                            ),
                            BoxShadow(
                              color: Theme.of(context).primaryColor,
                              blurRadius: 10,
                              spreadRadius: -5,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 40,
                        ),
                        child: Column(
                          children: [
                            const Text(
                              '나의 패스',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            if (me.activeProduct.id == 'free')
                              const SizedBox(height: 8),
                            Text(
                              me.activeProduct.id == 'free'
                                  ? '현재 사용 중인 패스가 없어요.'
                                  : '현재 사용 중인 패스를 확인할 수 있어요.',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            if (me.activeProduct.id != 'free')
                              const SizedBox(height: 20),
                            if (me.activeProduct.id != 'free')
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 400,
                                ),
                                child: _buildPass(context, me),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildInfo('상세한 결제 내역은 앱스토어 또는 플레이스토어 내에서 확인이 가능합니다.'),
                      _buildInfo('결제 및 구매 취소 관련 문의는 실감 카카오톡 채널을 이용해주세요.'),
                      _buildInfo(
                          '구독기간 이후에는 자동으로 서비스 권한이 만료되며, 추가 결제가 발생하지 않습니다.')
                    ],
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPass(BuildContext context, User user) {
    final isTrial = user.isProductTrial;
    final purchaseDateString =
        DateFormat.yMd('ko_KR').add_Hm().format(user.receipts.last.createdAt);
    final expiryDate = isTrial
        ? DateTime.parse(user.receipts.last.token).toLocal()
        : user.activeProduct.expiryDate;
    final expiryDateString =
        DateFormat.yMd('ko_KR').add_Hm().format(expiryDate);
    final expiryDDay = expiryDate.difference(DateTime.now()).inDays;
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              alignment: Alignment.center,
              height: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isTrial
                      ? [const Color(0xFFEB7F3C), const Color(0xFF3E49F5)]
                      : [const Color(0xFF75FBDA), const Color(0xFF3E49F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Text(
                'D-$expiryDDay',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Image.asset(
                        'assets/app_icon/app_icon_transparent.png',
                        color: Colors.grey.shade100,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 36),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            user.activeProduct.name,
                            maxLines: 1,
                            style: TextStyle(
                              fontFamily: 'EstablishRetrosans',
                              fontSize: 22,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${user.activeProduct.trialPeriod}일 무료 체험',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isTrial
                              ? Colors.grey.shade700
                              : Colors.transparent,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(
                        indent: 8,
                        endIndent: 8,
                        height: 1,
                        thickness: 1,
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Text(
                              '구매 일자',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                purchaseDateString,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Text(
                              '이용 가능 기간',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '~ $expiryDateString',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                  height: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w300,
              color: Colors.grey,
              height: 1.2,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.grey,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
