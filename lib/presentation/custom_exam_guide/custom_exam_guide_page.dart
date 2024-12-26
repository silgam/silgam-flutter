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

  final ScrollController _scrollController = ScrollController();
  bool _isMenuBarTransparent = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final isMenuBarTransparent = _scrollController.position.pixels <= 0;
      if (isMenuBarTransparent != _isMenuBarTransparent) {
        setState(() {
          _isMenuBarTransparent = isMenuBarTransparent;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

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

  Widget _buildGuideImages() {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = EdgeInsets.symmetric(
      horizontal: max(0, (screenWidth - _maxWidth) / 2),
    );

    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).padding.top,
          color: const Color(0xFF090B1E),
        ),
        Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0, 660 / 1062],
              colors: [
                Colors.black.withAlpha(204),
                Colors.black.withAlpha(0),
              ],
            ),
          ),
          child: Image.asset(
            'assets/custom_exam_guide_1.png',
            fit: BoxFit.contain,
          ),
        ),
        Padding(
          padding: padding,
          child: Image.asset(
            'assets/custom_exam_guide_2.png',
            fit: BoxFit.contain,
          ),
        ),
        Padding(
          padding: padding,
          child: Image.asset(
            'assets/custom_exam_guide_3.png',
            fit: BoxFit.contain,
          ),
        ),
        Padding(
          padding: padding,
          child: Image.asset(
            'assets/custom_exam_guide_4.png',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 16 + MediaQuery.of(context).padding.left,
        right: 16 + MediaQuery.of(context).padding.right,
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
    return AnnotatedRegion(
      value: defaultSystemUiOverlayStyle.copyWith(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: _buildGuideImages(),
                  ),
                ),
                _buildBottomButton(),
              ],
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              color: _isMenuBarTransparent
                  ? Colors.transparent
                  : Theme.of(context).primaryColor,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
                left: MediaQuery.of(context).padding.left,
                right: MediaQuery.of(context).padding.right,
              ),
              child: const CustomMenuBar(
                title: '나만의 과목 이용 안내',
                lightText: true,
              ),
            ),
          ],
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
