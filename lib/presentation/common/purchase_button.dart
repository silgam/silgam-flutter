import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../model/product.dart';
import '../purchase_page/purchase_page.dart';
import 'custom_card.dart';

class PurchaseButton extends StatelessWidget {
  const PurchaseButton({
    super.key,
    required this.product,
    this.margin,
  });

  final Product product;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      margin: margin,
      backgroundColor: Theme.of(context).primaryColor,
      isThin: true,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            PurchasePage.routeName,
            arguments: PurchasePageArguments(product: product),
          );
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.grey.withAlpha(60),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${product.name} 구매하기',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                color: Colors.white.withAlpha(150),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
