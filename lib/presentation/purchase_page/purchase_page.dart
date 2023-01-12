import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../util/injection.dart';
import '../common/menu_bar.dart';
import 'cubit/purchase_cubit.dart';

class PurchasePage extends StatelessWidget {
  PurchasePage({super.key});

  static const routeName = '/purchase';
  final PurchaseCubit _cubit = getIt.get();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _cubit,
      child: Scaffold(
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
                      onPressed: () => _cubit.purchaseProduct(productDetails),
                      child: const Text('test'),
                    )
                  ],
                );
              },
              orElse: () {
                return Container();
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
