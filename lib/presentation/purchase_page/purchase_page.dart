import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../model/product.dart';
import '../../util/injection.dart';
import '../app/cubit/app_cubit.dart';
import '../app/cubit/iap_cubit.dart';
import '../common/custom_menu_bar.dart';
import '../home_page/cubit/home_cubit.dart';
import '../home_page/settings/settings_view.dart';
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
    return BlocProvider(
      create: (context) => _cubit,
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: BlocListener<AppCubit, AppState>(
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
            child: BlocListener<IapCubit, IapState>(
              listener: (context, state) {
                if (state.isLoading) {
                  EasyLoading.show();
                } else {
                  EasyLoading.dismiss();
                }
              },
              child: BlocBuilder<PurchaseCubit, PurchaseState>(
                builder: (context, state) {
                  return Column(
                    children: [
                      CustomMenuBar(
                        title: widget.product.name,
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
    if (message.message == "purchase") {
      iapCubit.purchaseProduct(widget.product);
    } else if (message.message == "trial") {
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
                  '무료 체험 기간이 끝난 후, 체험 기간 중 작성한 실모 기록은 ${appCubit.state.freeProductBenefit.examRecordLimit}개까지만 열람하실 수 있습니다.',
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
                  iapCubit.startFreeTrial(widget.product);
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
