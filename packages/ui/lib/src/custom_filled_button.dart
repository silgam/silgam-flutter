import 'package:flutter/material.dart';

class CustomFilledButton extends StatelessWidget {
  const CustomFilledButton({
    super.key,
    required this.label,
    this.isLoading = false,
    this.onPressed,
    this.borderRadius = 12,
  });

  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        disabledBackgroundColor: isLoading ? Theme.of(context).primaryColor.withAlpha(180) : null,
        disabledForegroundColor: isLoading ? Colors.white : null,
      ),
      child:
          isLoading
              ? Padding(
                padding: const EdgeInsets.only(right: 4),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                ),
              )
              : Text(label),
    );
  }
}
