import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../util/injection.dart';
import '../../app/app.dart';
import '../../app/cubit/iap_cubit.dart';
import '../../common/custom_menu_bar.dart';
import '../../purchase/purchase_page.dart';

class SilgampassPage extends StatelessWidget {
  const SilgampassPage({super.key});

  static const routeName = '/products/silgampass';

  void _onIapStateChanged(BuildContext context, IapState state) {
    final product = state.sellingProduct;
    if (product != null) {
      Future(() {
        if (!context.mounted) return;

        Navigator.of(context).pushReplacementNamed(
          PurchasePage.routeName,
          arguments: PurchasePageArguments(product: product),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _onIapStateChanged(context, getIt.get<IapCubit>().state);

    return BlocListener<IapCubit, IapState>(
      listener: _onIapStateChanged,
      child: AnnotatedRegion(
        value: darkSystemUiOverlayStyle,
        child: Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          body: const SafeArea(
            child: Column(
              children: [
                CustomMenuBar(
                  title: '실감패스',
                  lightText: true,
                ),
                Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
