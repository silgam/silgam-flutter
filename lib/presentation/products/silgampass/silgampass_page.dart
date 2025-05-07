import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/ui.dart';

import '../../../util/injection.dart';
import '../../app/cubit/iap_cubit.dart';
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
      child: PageLayout(
        title: '실감패스',
        onBackPressed: () => Navigator.pop(context),
        backgroundColor: Theme.of(context).primaryColor,
        textBrightness: Brightness.light,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white)),
      ),
    );
  }
}
