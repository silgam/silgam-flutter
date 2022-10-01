import 'package:flutter/material.dart';

class MenuBar extends StatelessWidget {
  final String title;
  final List<ActionButton> actionButtons;
  final bool lightText;

  const MenuBar({
    Key? key,
    this.title = '',
    this.actionButtons = const [],
    this.lightText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color textColor = Colors.black;
    if (lightText) textColor = Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Material(
            type: MaterialType.transparency,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              splashRadius: 20,
              color: textColor,
            ),
          ),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
          for (ActionButton button in actionButtons)
            Material(
              type: MaterialType.transparency,
              child: IconButton(
                key: button.key,
                onPressed: button.onPressed,
                icon: button.icon,
                splashRadius: 20,
                tooltip: button.tooltip,
                color: textColor,
              ),
            ),
        ],
      ),
    );
  }
}

class ActionButton {
  final Widget icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Key? key;

  const ActionButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.key,
  });
}
