import 'package:flutter/material.dart';

enum TextButtonVariant {
  primary,
  secondary,
  destructive,
}

class CustomTextButton extends StatelessWidget {
  const CustomTextButton._({
    super.key,
    required this.variant,
    required this.text,
    this.onPressed,
  });

  factory CustomTextButton.primary({
    Key? key,
    required String text,
    VoidCallback? onPressed,
  }) =>
      CustomTextButton._(
        key: key,
        variant: TextButtonVariant.primary,
        text: text,
        onPressed: onPressed,
      );

  factory CustomTextButton.secondary({
    Key? key,
    required String text,
    VoidCallback? onPressed,
  }) =>
      CustomTextButton._(
        key: key,
        variant: TextButtonVariant.secondary,
        text: text,
        onPressed: onPressed,
      );

  factory CustomTextButton.destructive({
    Key? key,
    required String text,
    VoidCallback? onPressed,
  }) =>
      CustomTextButton._(
        key: key,
        variant: TextButtonVariant.destructive,
        text: text,
        onPressed: onPressed,
      );

  final TextButtonVariant variant;
  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: _getButtonStyle(),
      child: Text(text),
    );
  }

  ButtonStyle? _getButtonStyle() {
    return switch (variant) {
      TextButtonVariant.primary => null,
      TextButtonVariant.secondary => TextButton.styleFrom(
          foregroundColor: Colors.grey.shade600,
        ),
      TextButtonVariant.destructive => TextButton.styleFrom(
          foregroundColor: Colors.red,
        ),
    };
  }
}
