import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'custom_app_bar.dart';
import 'custom_filled_button.dart';

class PageLayoutBottomAction {
  const PageLayoutBottomAction({required this.label, this.onPressed});

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
    this.isBottomActionLoading = false,
    this.unfocusOnTapBackground = false,
    this.textBrightness = Brightness.dark,
    this.backgroundColor,
    required this.child,
    this.floatingActionButton,
  });

  final String? title;
  final VoidCallback? onBackPressed;
  final List<AppBarAction> appBarActions;
  final PageLayoutBottomAction? bottomAction;
  final bool isBottomActionLoading;
  final bool unfocusOnTapBackground;
  final Brightness textBrightness;
  final Color? backgroundColor;
  final Widget child;
  final Widget? floatingActionButton;

  @override
  State<PageLayout> createState() => _PageLayoutState();
}

class _PageLayoutState extends State<PageLayout> {
  static const SystemUiOverlayStyle _lightSystemUiOverlayStyle = SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.dark,
  );

  static const SystemUiOverlayStyle _darkSystemUiOverlayStyle = SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.black,
    systemNavigationBarIconBrightness: Brightness.light,
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.light,
  );

  double _maxBottomInset = 0;
  double _lastBottomInset = 0;
  bool _isKeyboardVisible = false;

  /// [_BottomButton]에 전달될 [_isKeyboardVisible] 값을 계산하기 위한 함수.
  ///
  /// 키보드가 올라온 경우에는 [_BottomButton]이 키보드 바로 위에 위치하기 때문에 디자인 변경이 필요.
  ///
  /// 구현 참고:
  ///
  /// * 키보드 종류에 따라 높이가 다를 수 있음.
  ///   (iOS에서 텍스트, 숫자, 이모지 키보드의 높이가 각각 다름)
  /// * 키보드 올라오는, 내려가는 애니메이션이 없거나 기기마다 다를 수 있음.
  /// * 키보드가 다 올라간 후 또는 다 내려간 후에 [_isKeyboardVisible] 값이 변경되면 어색함.
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

    final resultWidget = AnnotatedRegion(
      value: widget.textBrightness == Brightness.dark
          ? _lightSystemUiOverlayStyle
          : _darkSystemUiOverlayStyle.copyWith(systemNavigationBarColor: widget.backgroundColor),
      child: Scaffold(
        backgroundColor: widget.backgroundColor,
        floatingActionButton: widget.floatingActionButton,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomAppBar(
                title: widget.title,
                onBackPressed: widget.onBackPressed,
                actions: widget.appBarActions,
                ignoreButtonPress: widget.isBottomActionLoading,
                textBrightness: widget.textBrightness,
              ),
              Expanded(
                child: bottomAction != null
                    ? Stack(children: [widget.child, _BottomFadeGradient()])
                    : widget.child,
              ),
              if (bottomAction != null)
                _BottomButton(
                  label: bottomAction.label,
                  isKeyboardVisible: _isKeyboardVisible,
                  isLoading: widget.isBottomActionLoading,
                  onPressed: bottomAction.onPressed,
                ),
            ],
          ),
        ),
      ),
    );

    if (widget.unfocusOnTapBackground) {
      return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: resultWidget,
      );
    }

    return resultWidget;
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
              stops: const [0, 0.4, 1],
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
    required this.isLoading,
    this.onPressed,
  });

  static const _animationDuration = Duration(milliseconds: 50);

  final String label;
  final bool isKeyboardVisible;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: _animationDuration,
      padding: EdgeInsets.only(
        left: isKeyboardVisible ? 0 : 16,
        right: isKeyboardVisible ? 0 : 16,
        bottom: isKeyboardVisible ? 0 : 12,
      ),
      child: TweenAnimationBuilder(
        duration: _animationDuration,
        tween: Tween<double>(begin: 12, end: isKeyboardVisible ? 0 : 12),
        builder: (context, value, child) {
          return CustomFilledButton(
            label: label,
            isLoading: isLoading,
            onPressed: onPressed,
            borderRadius: value,
          );
        },
      ),
    );
  }
}
