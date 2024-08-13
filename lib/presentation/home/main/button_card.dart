part of 'main_view.dart';

class _ButtonCard extends StatelessWidget {
  final GestureTapCallback onTap;
  final String title;
  final IconData iconData;
  final bool primary;

  const _ButtonCard({
    required this.onTap,
    required this.title,
    required this.iconData,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      backgroundColor: primary ? Theme.of(context).primaryColor : Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      isThin: true,
      child: InkWell(
        onTap: _onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.grey.withAlpha(60),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const SizedBox(width: 4),
              Icon(
                iconData,
                color: primary ? Colors.white : Colors.black,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: primary ? Colors.white : Colors.black,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: primary ? Colors.white : Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTap() {
    onTap();
    AnalyticsManager.logEvent(
      name: '[HomePage-main] Action button tapped',
      properties: {'title': title},
    );
  }
}
