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
  final PageController _controller = PageController();
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    const animationDuration = Duration(milliseconds: 500);
    const animationCurve = Curves.ease;
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_controller.page == widget.ads.length - 1) {
        _controller.animateToPage(0, duration: animationDuration, curve: animationCurve);
      } else {
        _controller.nextPage(duration: animationDuration, curve: animationCurve);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2,
      child: _Card(
        child: PageView(
          controller: _controller,
          children: [
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
      ),
    );
  }

  void _onAdsTap(Ads ads) {
    String? url = ads.url;
    if (url == null) return;
    launch(url);
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }
}
