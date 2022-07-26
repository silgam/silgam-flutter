import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'const.dart';

class AdTile extends StatefulWidget {
  final AdSize adSize;
  final EdgeInsetsGeometry? margin;

  const AdTile({Key? key, required this.adSize, this.margin}) : super(key: key);

  @override
  State<AdTile> createState() => AdTileState();
}

class AdTileState extends State<AdTile> {
  BannerAd? _bannerAd;
  AdSize? _adSize;

  @override
  void initState() {
    super.initState();
    loadAd();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _bannerAd;
    final adSize = _adSize;
    if (ad == null || adSize == null) {
      return const SizedBox.shrink();
    }

    return Container(
      height: adSize.height.toDouble(),
      margin: widget.margin,
      child: AdWidget(
        ad: ad,
      ),
    );
  }

  Future<void> loadAd() async {
    await _bannerAd?.dispose();
    setState(() {
      _bannerAd = null;
      _adSize = null;
    });

    _bannerAd = BannerAd(
      size: widget.adSize,
      adUnitId: bannerAdId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: ((Ad ad) async {
          final bannerAd = ad as BannerAd;
          final adSize = await bannerAd.getPlatformAdSize();
          setState(() {
            _bannerAd = _bannerAd;
            _adSize = adSize;
          });
        }),
        onAdFailedToLoad: ((ad, error) {
          ad.dispose();
        }),
      ),
    )..load();
  }
}
