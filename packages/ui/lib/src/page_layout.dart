import 'package:flutter/material.dart';

class PageLayoutBottomAction {
  const PageLayoutBottomAction({
    required this.label,
    this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;
}

class PageLayout extends StatefulWidget {
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
  State<PageLayout> createState() => _PageLayoutState();
}

class _PageLayoutState extends State<PageLayout> {
  double _maxBottomInset = 0;
  double _lastBottomInset = 0;
  bool _isKeyboardVisible = false;

  void _updateKeyboardVisibility(double bottomInset) {
    if (bottomInset > _maxBottomInset) {
      _maxBottomInset = bottomInset;
    }

    final bool isKeyboardShowingUp = bottomInset > _lastBottomInset;
    final double keyboardVisibleRatio = bottomInset / _maxBottomInset;
    if (isKeyboardShowingUp && keyboardVisibleRatio > 0.3) {
      _isKeyboardVisible = true;
    } else if (!isKeyboardShowingUp && keyboardVisibleRatio < 0.7) {
      _isKeyboardVisible = false;
    }

    _lastBottomInset = bottomInset;
  }

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.of(context).viewInsets.bottom;
    _updateKeyboardVisibility(bottomInset);

    final bottomAction = widget.bottomAction;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AppBar(
              title: widget.title,
              onBackPressed: widget.onBackPressed,
              actions: widget.appBarActions,
            ),
            Expanded(
              child: bottomAction != null
                  ? Stack(
                      children: [
                        widget.child,
                        _BottomFadeGradient(),
                      ],
                    )
                  : widget.child,
            ),
            if (bottomAction != null)
              _BottomButton(
                label: bottomAction.label,
                isKeyboardVisible: _isKeyboardVisible,
                onPressed: bottomAction.onPressed,
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

class _BottomButton extends StatelessWidget {
  const _BottomButton({
    required this.label,
    required this.isKeyboardVisible,
    this.onPressed,
  });

  static const _animationDuration = Duration(milliseconds: 50);

  final String label;
  final bool isKeyboardVisible;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: _animationDuration,
      padding: EdgeInsets.symmetric(horizontal: isKeyboardVisible ? 0 : 16),
      child: TweenAnimationBuilder(
        duration: _animationDuration,
        tween: Tween<double>(begin: 12, end: isKeyboardVisible ? 0 : 12),
        builder: (context, value, child) {
          return FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(value),
              ),
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: child,
          );
        },
        child: Text(label),
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
