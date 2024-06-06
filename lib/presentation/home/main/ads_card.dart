part of 'main_view.dart';

class AdsCard extends StatefulWidget {
  final List<Ads> ads;

  const AdsCard({
    Key? key,
    required this.ads,
  }) : super(key: key);

  @override
  State<AdsCard> createState() => _AdsCardState();
}

class _AdsCardState extends State<AdsCard> {
  int _currentPageIndex = 0;
  final MainCubit _mainCubit = getIt.get();

  @override
  void initState() {
    super.initState();
    _onPageChanged(0, null);
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CarouselSlider(
            options: CarouselOptions(
              aspectRatio: 2,
              viewportFraction: 1,
              autoPlay: widget.ads.length > 1,
              enableInfiniteScroll: widget.ads.length > 1,
              onPageChanged: _onPageChanged,
            ),
            items: [
              for (final (index, ads) in widget.ads.indexed)
                VisibilityDetector(
                  key: Key('$index ${ads.imagePath}'),
                  onVisibilityChanged: (info) =>
                      _onVisibilityChanged(index, info),
                  child: GestureDetector(
                    onTap: () => _onAdsTap(ads, index),
                    child: CachedNetworkImage(
                      imageUrl: ads.imagePath,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Center(
                        child: Icon(
                          Icons.image,
                          size: 32,
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (widget.ads.length > 1)
            Padding(
              padding: const EdgeInsets.all(4),
              child: AnimatedSmoothIndicator(
                activeIndex: _currentPageIndex,
                count: widget.ads.length,
                effect: WormEffect(
                  dotWidth: 6,
                  dotHeight: 6,
                  dotColor: Colors.white.withAlpha(50),
                  activeDotColor: Colors.white.withAlpha(150),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _onPageChanged(int index, _) {
    VisibilityDetectorController.instance.notifyNow();
    _currentPageIndex = index;
    setState(() {});
  }

  void _onAdsTap(Ads ads, int index) {
    AnalyticsManager.logEvent(
      name: '[HomePage-main] Silgam ads tapped',
      properties: {
        'title': ads.title,
        'actionIntents': ads.actions.map((e) => e.intent.toString()).join(', '),
        'actionData': ads.actions.map((e) => e.data).join(', '),
        'priority': ads.priority,
        'order': index + 1,
      },
    );

    for (final action in ads.actions) {
      switch (action.intent) {
        case AdsIntent.openUrl:
          launchUrl(Uri.parse(action.data),
              mode: LaunchMode.externalApplication);
          break;
        case AdsIntent.openAdUrl:
          launchUrl(Uri.parse(action.data),
              mode: LaunchMode.externalApplication);
          break;
        case AdsIntent.openPurchasePage:
          final productId = action.data;
          final product = getIt
              .get<IapCubit>()
              .state
              .products
              .firstWhereOrNull((p) => p.id == productId);
          if (product != null) {
            Navigator.of(context).pushNamed(
              PurchasePage.routeName,
              arguments: PurchasePageArguments(product: product),
            );
          }
          break;
        case AdsIntent.openOfflineGuidePage:
          Navigator.of(context).pushNamed(OfflineGuidePage.routeName);
          break;
        case AdsIntent.openCustomExamGuidePage:
          Navigator.of(context).pushNamed(CustomExamGuidePage.routeName);
          break;
        case AdsIntent.unknown:
          break;
      }
    }
  }

  void _onVisibilityChanged(int index, VisibilityInfo info) {
    if (info.visibleFraction > 0.5) {
      Ads ads = widget.ads[index];
      _mainCubit.onAdsShown(index, ads);
    }
  }
}
