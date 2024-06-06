import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../util/injection.dart';
import '../app/app.dart';
import '../app/cubit/app_cubit.dart';
import '../app/cubit/iap_cubit.dart';
import '../common/custom_menu_bar.dart';
import '../custom_exam_list/custom_exam_list_page.dart';
import '../purchase/purchase_page.dart';

class CustomExamGuidePage extends StatefulWidget {
  const CustomExamGuidePage({
    super.key,
    required this.isFromCustomExamListPage,
    required this.isFromPurchasePage,
  });

  static const routeName = '/custom_exam_guide';

  final bool isFromCustomExamListPage;
  final bool isFromPurchasePage;

  @override
  State<CustomExamGuidePage> createState() => _CustomExamGuidePageState();
}

class _CustomExamGuidePageState extends State<CustomExamGuidePage> {
  static const _maxWidth = 550.0;

  final AppCubit _appCubit = getIt.get();
  final IapCubit _iapCubit = getIt.get();

  void _onBottomButtonTap() {
    if (_appCubit.state.productBenefit.isCustomExamAvailable) {
      if (widget.isFromCustomExamListPage) {
        Navigator.pop(context);
      } else {
        Navigator.pushNamed(context, CustomExamListPage.routeName);
      }
      return;
    }

    if (widget.isFromPurchasePage) {
      Navigator.pop(context);
    } else {
      final sellingProduct = _iapCubit.state.sellingProduct;
      if (sellingProduct == null) return;

      Navigator.pushNamed(
        context,
        PurchasePage.routeName,
        arguments: PurchasePageArguments(product: sellingProduct),
      );
    }
  }

  Widget _buildBottomButton() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 12 + MediaQuery.of(context).padding.bottom,
      ),
      child: Material(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _onBottomButtonTap,
          splashColor: Colors.transparent,
          highlightColor: Colors.grey.withAlpha(60),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14,
            ),
            child: BlocBuilder<AppCubit, AppState>(
              builder: (context, state) {
                return Text(
                  state.productBenefit.isCustomExamAvailable
                      ? '나만의 과목 만들어보기'
                      : '실감패스 구매하러 가기',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return AnnotatedRegion(
      value: defaultSystemUiOverlayStyle.copyWith(
        statusBarColor: Theme.of(context).primaryColor,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const CustomMenuBar(
                title: '나만의 과목 이용 안내',
                lightText: true,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: max(0, (screenWidth - _maxWidth) / 2),
                    ),
                    // TODO: 내용 바꾸기
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/offline_guide_1.png',
                          fit: BoxFit.contain,
                        ),
                        Image.asset(
                          'assets/offline_guide_2.png',
                          fit: BoxFit.contain,
                        ),
                        Image.asset(
                          'assets/offline_guide_3.png',
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
              _buildBottomButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomExamGuideArguments {
  final bool isFromCustomExamListPage;
  final bool isFromPurchasePage;

  const CustomExamGuideArguments({
    this.isFromCustomExamListPage = false,
    this.isFromPurchasePage = false,
  });
}
