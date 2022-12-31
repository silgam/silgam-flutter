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
          child: Column(
            children: const [
              MenuBar(title: 'Purchase Page'),
            ],
          ),
        ),
      ),
    );
  }
}
