import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../model/product.dart';
import '../app/cubit/iap_cubit.dart';
import '../common/menu_bar.dart';

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
  late final IapCubit _iapCubit;

  @override
  void initState() {
    super.initState();
    _iapCubit = context.read<IapCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _iapCubit.state.whenOrNull(
        storeUnavailable: () => _onStoreUnavailable(context),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const MenuBar(title: 'Purchase Page'),
            TextButton(
              onPressed: () => _iapCubit.startFreeTrial(widget.product),
              child: Text('${widget.product.name} 체험하기'),
            ),
            TextButton(
              onPressed: () => _iapCubit.purchaseProduct(widget.productDetail),
              child: Text('${widget.product.name} 구매하기'),
            ),
          ],
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
