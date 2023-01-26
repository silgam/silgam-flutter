import 'package:flutter/material.dart' hide MenuBar;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../model/product.dart';
import '../../util/injection.dart';
import '../app/cubit/iap_cubit.dart';
import '../common/menu_bar.dart';
import 'cubit/purchase_cubit.dart';

class PurchasePage extends StatefulWidget {
  const PurchasePage({
    super.key,
    required this.product,
    required this.productDetail,
  });

  static const routeName = '/purchase';
  final Product product;
  final ProductDetails productDetail;

  @override
  State<PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {
  final PurchaseCubit _cubit = getIt.get();
  late final IapCubit _iapCubit = context.read<IapCubit>();

  late final backgroundColor =
      Color(int.parse(widget.product.pageBackgroundColor));
  late final WebViewController _webViewController = WebViewController()
    ..enableZoom(false)
    ..setBackgroundColor(backgroundColor)
    ..setNavigationDelegate(NavigationDelegate(
      onProgress: _cubit.onWebviewProgressChanged,
    ))
    ..addJavaScriptChannel(
      'FlutterWebView',
      onMessageReceived: (message) {
        if (message.message == "purchase") {
          _iapCubit.purchaseProduct(widget.productDetail);
        } else if (message.message == "trial") {
          _iapCubit.startFreeTrial(widget.product);
        }
      },
    )
    ..loadRequest(
      Uri.parse(widget.product.pageUrl),
    );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _iapCubit.state.mapOrNull(
        storeUnavailable: (_) => _onStoreUnavailable(context),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _cubit,
      child: Scaffold(
        body: SafeArea(
          bottom: false,
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
                    MenuBar(
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
    );
  }

  void _onStoreUnavailable(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '이 기기에서는 구매가 불가능합니다. 스토어가 설치되어 있는지 확인해주세요.',
        ),
      ),
    );
    Navigator.of(context).pop();
  }
}

class PurchasePageArguments {
  const PurchasePageArguments({
    required this.product,
    required this.productDetail,
  });

  final Product product;
  final ProductDetails productDetail;
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
