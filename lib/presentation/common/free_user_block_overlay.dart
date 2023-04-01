import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app/cubit/iap_cubit.dart';
import 'purchase_button.dart';

class FreeUserBlockOverlay extends StatelessWidget {
  const FreeUserBlockOverlay({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withOpacity(0.65),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          BlocBuilder<IapCubit, IapState>(
            builder: (context, iapState) {
              final product = iapState.activeProducts.firstOrNull;
              if (product == null) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 20),
                child: PurchaseButton(
                  product: iapState.activeProducts.first,
                  expand: false,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
