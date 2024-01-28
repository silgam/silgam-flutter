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
              for (Ads ads in widget.ads)
                GestureDetector(
                  onTap: () => _onAdsTap(ads),
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
    _currentPageIndex = index;
    setState(() {});
  }

  void _onAdsTap(Ads ads) {
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
        case AdsIntent.unknown:
          break;
      }
    }

    AnalyticsManager.logEvent(
      name: '[HomePage-main] Silgam ads tapped',
      properties: {
        'title': ads.title,
        'actionIntents': ads.actions.map((e) => e.intent.toString()).join(', '),
        'actionData': ads.actions.map((e) => e.data).join(', '),
        'priority': ads.priority,
      },
    );
  }
}
