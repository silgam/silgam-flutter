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
    this.expand = true,
  });

  final Product product;
  final EdgeInsetsGeometry? margin;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      margin: margin,
      width: expand ? double.infinity : null,
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 12),
              Text(
                '${product.name} 확인하기',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              if (expand) const Spacer(),
              if (!expand) const SizedBox(width: 12),
              Icon(
                CupertinoIcons.chevron_right,
                color: Colors.white.withAlpha(150),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
