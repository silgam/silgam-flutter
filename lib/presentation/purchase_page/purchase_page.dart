import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../common/menu_bar.dart';
import 'cubit/purchase_cubit.dart';

class PurchasePage extends StatefulWidget {
  const PurchasePage({super.key});

  static const routeName = '/purchase';

  @override
  State<PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {
  late final PurchaseCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<PurchaseCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cubit.state.whenOrNull(
        storeUnavailable: () => _onStoreUnavailable(context),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<PurchaseCubit, PurchaseState>(
          listener: (context, state) {
            state.whenOrNull(
              storeUnavailable: () => _onStoreUnavailable(context),
            );
          },
          builder: (context, state) => state.maybeWhen(
            loaded: (product, productDetails) {
              return Column(
                children: [
                  const MenuBar(title: 'Purchase Page'),
                  TextButton(
                    onPressed: () => _cubit.startFreeTrial(product),
                    child: Text('${product.name} 체험하기'),
                  ),
                  TextButton(
                    onPressed: () => _cubit.purchaseProduct(productDetails),
                    child: Text('${product.name} 구매하기'),
                  ),
                ],
              );
            },
            orElse: () {
              return const SizedBox.shrink();
            },
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
