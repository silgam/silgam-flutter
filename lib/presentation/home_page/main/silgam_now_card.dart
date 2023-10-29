part of 'main_view.dart';

class _SilgamNowCard extends StatefulWidget {
  const _SilgamNowCard() : super();

  @override
  State<_SilgamNowCard> createState() => _SilgamNowCardState();
}

class _SilgamNowCardState extends State<_SilgamNowCard> {
  Timer? _updateTimer;
  StreamSubscription? _onlineDevicesCountSubscription;
  StreamSubscription? _minOnlineDevicesShowingCountSubscription;
  int _onlineDevicesCount = 0;
  int? _minOnlineDevicesShowingCount;

  @override
  void initState() {
    super.initState();
    _onlineDevicesCountSubscription = FirebaseDatabase.instance
        .ref('stats/onlineDevicesCount')
        .onValue
        .listen((event) {
      _onlineDevicesCount = int.tryParse(event.snapshot.value.toString()) ?? 0;
    });
    _minOnlineDevicesShowingCountSubscription = FirebaseDatabase.instance
        .ref('stats/minOnlineDevicesShowingCount')
        .onValue
        .listen((event) {
      _minOnlineDevicesShowingCount =
          int.tryParse(event.snapshot.value.toString());
    });
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _updateTimer?.cancel();
    _onlineDevicesCountSubscription?.cancel();
    _minOnlineDevicesShowingCountSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      buildWhen: (previous, current) => previous.isOffline != current.isOffline,
      builder: (context, appState) {
        if (appState.isOffline ||
            _minOnlineDevicesShowingCount == null ||
            _onlineDevicesCount < _minOnlineDevicesShowingCount!) {
          return const SizedBox.shrink();
        }
        return CustomCard(
          isThin: true,
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: IntrinsicHeight(
            child: Row(
              children: [
                const SizedBox(width: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '실감',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'NOW',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w900,
                        shadows: [
                          Shadow(
                            color: Colors.red.withOpacity(0.2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 2),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 6),
                const VerticalDivider(),
                const SizedBox(width: 6),
                Flexible(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        height: 1.2,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        fontSize: 13,
                      ),
                      children: [
                        const TextSpan(text: '지금 '),
                        TextSpan(
                          text: '$_onlineDevicesCount명',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const TextSpan(text: ' 이 실감과 함께 공부하고 있어요 🔥'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
