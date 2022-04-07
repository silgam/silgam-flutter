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
  @override
  Widget build(BuildContext context) {
    return _Card(
      child: CarouselSlider(
        options: CarouselOptions(
          aspectRatio: 2,
          viewportFraction: 1,
          autoPlay: true,
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
    );
  }

  void _onAdsTap(Ads ads) {
    String? url = ads.url;
    if (url == null) return;
    launch(url);
  }
}
