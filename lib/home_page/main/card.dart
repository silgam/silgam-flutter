part of 'main_view.dart';

class _Card extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;

  const _Card({
    Key? key,
    required this.child,
    this.backgroundColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(cardCornerRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(24),
            offset: const Offset(0, 2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Material(
        color: backgroundColor,
        child: child,
      ),
    );
  }
}
