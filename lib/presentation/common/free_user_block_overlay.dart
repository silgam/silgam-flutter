import 'package:flutter/material.dart';

import 'purchase_button.dart';

class FreeUserBlockOverlay extends StatelessWidget {
  const FreeUserBlockOverlay({
    super.key,
    required this.text,
    this.overlayColor,
  });

  final String text;
  final Color? overlayColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: overlayColor ?? Colors.white.withOpacity(0.65),
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
          buildPurchaseButtonOr(
            margin: const EdgeInsets.only(top: 20),
            expand: false,
          ),
        ],
      ),
    );
  }
}
