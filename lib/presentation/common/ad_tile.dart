import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../util/const.dart';

class AdTile extends StatefulWidget {
  final int width;
  final EdgeInsetsGeometry? margin;

  const AdTile({
    super.key,
    required this.width,
    this.margin,
  });

  @override
  State<AdTile> createState() => AdTileState();
}

class AdTileState extends State<AdTile> {
  BannerAd? _bannerAd;
  AdSize? _adSize;
  bool _isLoaded = false;
  bool _isLoading = false;
  late Orientation _currentOrientation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentOrientation = MediaQuery.of(context).orientation;
    _loadAd();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (_currentOrientation != orientation) {
          _currentOrientation = orientation;
          _loadAd();
          return const SizedBox.shrink();
        }
        final bannerAd = _bannerAd;
        final adSize = _adSize;
        if (bannerAd == null || adSize == null || !_isLoaded) {
          return const SizedBox.shrink();
        }
        return Container(
          width: adSize.width.toDouble(),
          height: adSize.height.toDouble(),
          margin: widget.margin,
          child: AdWidget(
            ad: bannerAd,
          ),
        );
      },
    );
  }

  Future<void> _loadAd() async {
    if (_isLoading) return;
    _isLoading = true;

    await _bannerAd?.dispose();
    setState(() {
      _bannerAd = null;
      _adSize = null;
      _isLoaded = false;
    });

    _bannerAd = BannerAd(
      size: AdSize.getInlineAdaptiveBannerAdSize(widget.width, 100),
      adUnitId: bannerAdId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: ((Ad ad) async {
          final bannerAd = ad as BannerAd;
          final adSize = await bannerAd.getPlatformAdSize();
          if (adSize == null) {
            log('Error: getPlatformAdSize() returned null for $bannerAd');
            return;
          }

          setState(() {
            _bannerAd = _bannerAd;
            _adSize = adSize;
            _isLoaded = true;
            _isLoading = false;
          });
        }),
        onAdFailedToLoad: ((ad, error) {
          log('Failed to load a banner ad: $error');
          setState(() {
            _isLoaded = false;
            _isLoading = false;
          });
          ad.dispose();
        }),
      ),
    );
    await _bannerAd?.load();
  }
}
