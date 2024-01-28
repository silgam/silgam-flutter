import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../model/product.dart';
import '../../util/analytics_manager.dart';
import '../../util/injection.dart';
import '../app/app.dart';
import '../app/cubit/app_cubit.dart';
import '../app/cubit/iap_cubit.dart';
import '../common/custom_menu_bar.dart';
import '../home/cubit/home_cubit.dart';
import '../home/settings/settings_view.dart';
import 'cubit/purchase_cubit.dart';

class PurchasePage extends StatefulWidget {
  const PurchasePage({
    super.key,
    required this.product,
  });

  static const routeName = '/purchase';
  final Product product;

  @override
  State<PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {
  final AppCubit _appCubit = getIt.get();
  final PurchaseCubit _cubit = getIt.get();

  late final backgroundColor =
      Color(int.parse(widget.product.pageBackgroundColor));
  late final WebViewController _webViewController = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..enableZoom(false)
    ..setBackgroundColor(backgroundColor)
    ..setNavigationDelegate(NavigationDelegate(
      onProgress: _cubit.onWebviewProgressChanged,
    ))
    ..addJavaScriptChannel(
      'FlutterWebView',
      onMessageReceived: _onWebviewMessageReceived,
    )
    ..loadRequest(
      Uri.parse(widget.product.pageUrl),
    );

  @override
  Widget build(BuildContext context) {
    if (_appCubit.state.isOffline) {
      EasyLoading.showToast(
        '오프라인 상태에서는 실감패스를 확인할 수 없어요.',
        dismissOnTap: true,
      );
      Navigator.of(context).pop();
    }

    return BlocProvider(
      create: (context) => _cubit,
      child: MultiBlocListener(
        listeners: [
          BlocListener<AppCubit, AppState>(
            listenWhen: (previous, current) => previous.me != current.me,
            listener: (context, state) {
              final me = state.me;
              if (me != null && me.activeProduct.id == widget.product.id) {
                Navigator.of(context).pop();
                getIt.get<HomeCubit>().changeTabByTitle(SettingsView.title);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      me.isProductTrial
                          ? '${widget.product.name} ${widget.product.trialPeriod}일 무료 체험 기간이 시작되었어요 🔥'
                          : '${widget.product.name}가 시작되었어요! 열공하세요 🔥',
                    ),
                  ),
                );
              }
            },
          ),
          BlocListener<IapCubit, IapState>(
            listener: (context, state) {
              if (state.isLoading) {
                EasyLoading.show(status: '처리 중입니다. 앱을 닫지 마세요.');
              } else {
                EasyLoading.dismiss();
              }
            },
          ),
        ],
        child: AnnotatedRegion(
          value: defaultSystemUiOverlayStyle.copyWith(
            statusBarColor: backgroundColor,
            statusBarBrightness: widget.product.isPageBackgroundDark
                ? Brightness.dark
                : Brightness.light,
            statusBarIconBrightness: widget.product.isPageBackgroundDark
                ? Brightness.light
                : Brightness.dark,
          ),
          child: Scaffold(
            backgroundColor: backgroundColor,
            body: SafeArea(
              bottom: false,
              child: BlocBuilder<PurchaseCubit, PurchaseState>(
                builder: (context, state) {
                  return Column(
                    children: [
                      CustomMenuBar(
                        title: widget.product.name,
                        lightText: widget.product.isPageBackgroundDark,
                      ),
                      Expanded(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Container(
                              color: backgroundColor,
                              alignment: Alignment.center,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: widget.product.isPageBackgroundDark
                                    ? Colors.white
                                    : Theme.of(context).primaryColor,
                              ),
                            ),
                            AnimatedOpacity(
                              opacity: state.isWebviewLoading ? 0 : 1,
                              curve: const _DelayedCurve(0.3, Curves.easeInOut),
                              duration: const Duration(milliseconds: 500),
                              child:
                                  WebViewWidget(controller: _webViewController),
                            ),
                            AnimatedOpacity(
                              opacity: state.isWebviewLoading ||
                                      state.isPurchaseSectionShown
                                  ? 0
                                  : 1,
                              curve: const _DelayedCurve(0.3, Curves.easeInOut),
                              duration: const Duration(milliseconds: 300),
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  color: Colors.white,
                                  padding: EdgeInsets.only(
                                    left: 16,
                                    right: 16,
                                    top: 12,
                                    bottom: 12 +
                                        MediaQuery.of(context).padding.bottom,
                                  ),
                                  child: Material(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(12),
                                    clipBehavior: Clip.antiAlias,
                                    child: InkWell(
                                      onTap: () {
                                        _webViewController.runJavaScript(
                                            'scrollToPurchaseSection()');
                                      },
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.grey.withAlpha(60),
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 14,
                                        ),
                                        child: const Text(
                                          '구매하기 / 체험하기',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onWebviewMessageReceived(JavaScriptMessage message) {
    final AppCubit appCubit = context.read();
    final IapCubit iapCubit = context.read();
    switch (message.message) {
      case 'purchaseSectionShown':
        _cubit.purchaseSectionShown();
        break;
      case 'purchaseSectionHidden':
        _cubit.purchaseSectionHidden();
        break;

      case 'purchase':
        AnalyticsManager.logEvent(
          name: '[PurchasePage] Webview message received',
          properties: {
            'message': message.message,
            'product_id': widget.product.id,
            'product_name': widget.product.name,
          },
        );
        iapCubit.purchaseProduct(widget.product);
        break;
      case 'trial':
        AnalyticsManager.logEvent(
          name: '[PurchasePage] Webview message received',
          properties: {
            'message': message.message,
            'product_id': widget.product.id,
            'product_name': widget.product.name,
          },
        );
        final now = DateFormat.yMd('ko_KR').add_Hm().format(DateTime.now());
        final trialEndTime = DateFormat.yMd('ko_KR').add_Hm().format(
              DateTime.now()
                  .add(Duration(days: widget.product.trialPeriod))
                  .subtract(const Duration(seconds: 1)),
            );
        showDialog(
          context: context,
          routeSettings:
              const RouteSettings(name: '/purchase/trial_confirm_dialog'),
          builder: (context) {
            return AlertDialog(
              title: Text(
                '${widget.product.name} ${widget.product.trialPeriod}일 무료 체험을 시작할까요?',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildInfo('이용 가능 기간 : $now ~ $trialEndTime'),
                  _buildInfo('실감패스 무료 체험판은 매년 판매되는 패스 구매 전 한 번만 사용 가능합니다.'),
                  _buildInfo(
                    '무료 체험 기간이 끝나는 시점까지 작성되어있는 모의고사 기록이 ${appCubit.state.freeProductBenefit.examRecordLimit}개를 초과하면, 체험 기간 후에는 모의고사 기록을 열람 및 삭제만 할 수 있습니다. (${appCubit.state.freeProductBenefit.examRecordLimit}개 미만까지 삭제할 시에만 추가/수정 가능)',
                  ),
                ],
              ),
              contentPadding: const EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.grey),
                  child: const Text(
                    '취소',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    AnalyticsManager.logEvent(
                      name: '[PurchasePage] Start free trial button tapped',
                      properties: {
                        'product_id': widget.product.id,
                        'product_name': widget.product.name,
                      },
                    );
                    iapCubit.startFreeTrialProcess(widget.product);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    '시작',
                  ),
                ),
              ],
            );
          },
        );
        break;
    }
  }

  Widget _buildInfo(String text) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w300,
              color: Colors.grey.shade600,
              height: 1.2,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey.shade600,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PurchasePageArguments {
  const PurchasePageArguments({
    required this.product,
  });

  final Product product;
}

class _DelayedCurve extends Curve {
  const _DelayedCurve(this.delay, this.curve);

  final double delay;
  final Curve curve;

  @override
  double transformInternal(double t) {
    if (t < delay) {
      return 0;
    }
    return curve.transformInternal((t - delay) / (1 - delay));
  }
}
