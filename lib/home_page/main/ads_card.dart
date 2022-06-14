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
    return _Card(
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
                  child: Image.network(
                    ads.imagePath,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: SizedBox(
                          width: 36,
                          height: 36,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
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
    String? url = ads.url;
    if (url == null) return;
    launch(url);
  }
}
