import 'dart:io';

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../model/product.dart';
import '../../model/user.dart';
import '../app/cubit/app_cubit.dart';
import '../app/cubit/iap_cubit.dart';
import '../common/custom_card.dart';
import '../common/custom_menu_bar.dart';
import '../common/purchase_button.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  static const routeName = '/my_page';
  static const _cardMaxWidth = 400.0;

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
                buildWhen: (previous, current) =>
                    previous.me != current.me ||
                    previous.productBenefit != current.productBenefit,
                builder: (context, appState) {
                  final me = appState.me;
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
                            const Text(
                              '현재 사용 중인 패스를 확인할 수 있어요.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (me.activeProduct.id != 'free')
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: _cardMaxWidth,
                                ),
                                child: _buildPass(context, me),
                              ),
                            if (me.activeProduct.id == 'free')
                              Container(
                                width: double.infinity,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                constraints: const BoxConstraints(
                                  maxWidth: _cardMaxWidth,
                                  minHeight: 120,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1,
                                  ),
                                ),
                                child: const Text(
                                  '앗! 사용 중인 패스가 없어요 :(',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      BlocBuilder<IapCubit, IapState>(
                        buildWhen: (previous, current) =>
                            previous.products != current.products ||
                            previous.activeProducts != current.activeProducts,
                        builder: (context, iapState) {
                          return Column(
                            children: [
                              if ((me.activeProduct.id == 'free' ||
                                      me.isProductTrial) &&
                                  iapState.activeProducts.isNotEmpty)
                                PurchaseButton(
                                  product: iapState.activeProducts.first,
                                  margin: const EdgeInsets.only(
                                    left: 24,
                                    right: 24,
                                    bottom: 40,
                                  ),
                                ),
                              if (me.receipts.isNotEmpty)
                                const Text(
                                  '사용 내역',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              const SizedBox(height: 8),
                              ...me.receipts.reversed.map((receipt) {
                                final product = iapState.products.firstWhere(
                                    (product) =>
                                        product.id == receipt.productId);
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                  ),
                                  constraints: const BoxConstraints(
                                    maxWidth: _cardMaxWidth,
                                  ),
                                  child: _buildReceipt(receipt, product),
                                );
                              }).toList(),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildInfo(
                          '상세한 결제 내역은 ${Platform.isAndroid ? '플레이스토어' : '앱스토어'} 내에서 확인이 가능합니다.'),
                      _buildInfo('결제 및 구매 취소 관련 문의는 실감 카카오톡 채널을 이용해주세요.'),
                      _buildInfo(
                        '구독기간 이후에는 자동으로 서비스 권한이 만료되며, 추가 결제가 발생하지 않습니다.',
                      ),
                      _buildInfo('실감패스 무료 체험판은 매년 판매되는 패스 구매 전 한 번만 사용 가능합니다.'),
                      _buildInfo(
                        '실감패스 이용 기간 중 작성한 모의고사 기록이 ${appState.freeProductBenefit.examRecordLimit}개를 초과할 경우, 실감패스 이용 기간 이후에는 기록을 추가하거나 기존의 기록을 수정할 수 없습니다. (열람 및 삭제만 가능) 단, 기록이 ${appState.freeProductBenefit.examRecordLimit}개 이하가 되도록 일부 기록을 삭제할 경우 추가 및 수정이 가능합니다.',
                      ),
                      _buildInfo(
                        '구매 취소 및 환불은 구입일로부터 7일 이내에만 가능하며, 환불 절차는 스토어의 운영 정책을 따릅니다.',
                      ),
                      const SizedBox(height: 60),
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
        DateFormat.yMd().add_Hm().format(user.receipts.last.createdAt);
    final expiryDate = isTrial
        ? DateTime.parse(user.receipts.last.token).toLocal()
        : user.activeProduct.expiryDate;
    final expiryDateString = DateFormat.yMd().add_Hm().format(expiryDate);

    final now = DateTime.now();
    final expiryDay =
        DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    final expiryDDay = expiryDay
        .difference(
          DateTime(now.year, now.month, now.day),
        )
        .inDays;
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
                        child: _buildReceiptInfo('시작 일시', purchaseDateString),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildReceiptInfo('만료 일시', expiryDateString),
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

  Widget _buildReceipt(Receipt receipt, Product product) {
    final isTrial = receipt.store == 'trial';
    final purchaseDateString =
        DateFormat.yMd().add_Hm().format(receipt.createdAt);
    final expiryDate =
        isTrial ? DateTime.parse(receipt.token).toLocal() : product.expiryDate;
    final expiryDateString = DateFormat.yMd().add_Hm().format(expiryDate);

    var store = '';
    switch (receipt.store) {
      case 'trial':
        store = '무료 체험';
        break;
      case 'google_play':
        store = 'Google Play';
        break;
      case 'app_store':
        store = 'App Store';
        break;
      case 'promotion':
        store = '프로모션';
        break;
    }

    return CustomCard(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              product.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          DottedLine(
            dashLength: 8,
            dashGapLength: 8,
            dashColor: Colors.grey.shade700,
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _buildReceiptInfo(
              '구매 방법',
              store,
              textColor: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _buildReceiptInfo(
              '구매 일시',
              purchaseDateString,
              textColor: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _buildReceiptInfo(
              '만료 일시',
              expiryDateString,
              textColor: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptInfo(
    String title,
    String text, {
    Color? textColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              height: 1.1,
              color: textColor ?? Colors.black,
            ),
          ),
        ),
      ],
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
