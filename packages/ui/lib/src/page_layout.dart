import 'package:flutter/material.dart';

class PageLayoutBottomAction {
  const PageLayoutBottomAction({
    required this.label,
    this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;
}

class PageLayout extends StatelessWidget {
  const PageLayout({
    super.key,
    this.title,
    this.onBackPressed,
    this.appBarActions = const [],
    this.bottomAction,
    required this.child,
  });

  final String? title;
  final VoidCallback? onBackPressed;
  final List<AppBarAction> appBarActions;
  final PageLayoutBottomAction? bottomAction;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bottomAction = this.bottomAction;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AppBar(
              title: title,
              onBackPressed: onBackPressed,
              actions: appBarActions,
            ),
            Expanded(
              child: bottomAction != null
                  ? Stack(
                      children: [
                        child,
                        _BottomFadeGradient(),
                      ],
                    )
                  : child,
            ),
            if (bottomAction != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FilledButton(
                  onPressed: bottomAction.onPressed,
                  style: FilledButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: Text(bottomAction.label),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BottomFadeGradient extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Positioned.fill(
      top: null,
      child: IgnorePointer(
        child: Container(
          height: 24,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0, 0.4, 1],
              colors: [
                backgroundColor.withAlpha(0),
                backgroundColor.withAlpha(70),
                backgroundColor,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppBarAction {
  final IconData iconData;
  final String tooltip;
  final VoidCallback? onPressed;

  const AppBarAction({
    required this.iconData,
    required this.tooltip,
    this.onPressed,
  });
}

class _AppBar extends StatelessWidget {
  const _AppBar({
    this.title,
    this.onBackPressed,
    this.actions = const [],
    this.lightText = false,
  });

  final String? title;
  final VoidCallback? onBackPressed;
  final List<AppBarAction> actions;
  final bool lightText;

  @override
  Widget build(BuildContext context) {
    final Color textColor = lightText ? Colors.white : Colors.black;

    final title = this.title;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onBackPressed,
            tooltip: '뒤로가기',
            splashRadius: 20,
            color: textColor,
            icon: const Icon(Icons.arrow_back),
          ),
          if (title != null)
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
            )
          else
            const Spacer(),
          for (AppBarAction action in actions)
            IconButton(
              onPressed: action.onPressed,
              tooltip: action.tooltip,
              splashRadius: 20,
              color: textColor,
              icon: Icon(action.iconData),
            ),
        ],
      ),
    );
  }
}
