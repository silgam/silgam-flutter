import 'package:flutter/material.dart';

class AppBarAction {
  final Key? key;
  final IconData iconData;
  final String tooltip;
  final VoidCallback? onPressed;

  const AppBarAction({this.key, required this.iconData, required this.tooltip, this.onPressed});
}

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({
    super.key,
    this.title,
    this.onBackPressed,
    this.actions = const [],
    this.ignoreButtonPress = false,
    this.textBrightness = Brightness.dark,
  });

  final String? title;
  final VoidCallback? onBackPressed;
  final List<AppBarAction> actions;
  final bool ignoreButtonPress;
  final Brightness textBrightness;

  @override
  Widget build(BuildContext context) {
    final Color textColor = textBrightness == Brightness.dark ? Colors.black : Colors.white;

    final title = this.title;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: IconButton(
              onPressed: ignoreButtonPress ? () {} : onBackPressed,
              tooltip: '뒤로가기',
              splashRadius: 20,
              color: textColor,
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          if (title != null)
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.w700),
              ),
            )
          else
            const Spacer(),
          for (AppBarAction action in actions)
            Material(
              color: Colors.transparent,
              child: IconButton(
                key: action.key,
                onPressed: ignoreButtonPress ? () {} : action.onPressed,
                tooltip: action.tooltip,
                splashRadius: 20,
                color: textColor,
                icon: Icon(action.iconData),
              ),
            ),
        ],
      ),
    );
  }
}
