import 'package:flutter/material.dart' hide MenuBar;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../model/product.dart';
import '../../util/injection.dart';
import '../app/cubit/app_cubit.dart';
import '../app/cubit/iap_cubit.dart';
import '../common/menu_bar.dart';
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
      onMessageReceived: (message) {
        final IapCubit iapCubit = context.read();
        if (message.message == "purchase") {
          iapCubit.purchaseProduct(widget.product);
        } else if (message.message == "trial") {
          iapCubit.startFreeTrial(widget.product);
        }
      },
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
              if (state.me?.activeProduct.id == widget.product.id) {
                Navigator.of(context).pop();
                getIt.get<HomeCubit>().changeTabByTitle(SettingsView.title);
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
