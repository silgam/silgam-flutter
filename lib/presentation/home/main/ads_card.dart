import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../model/ads.dart';
import '../../../util/injection.dart';
import '../../app/cubit/iap_cubit.dart';
import '../../common/custom_card.dart';
import '../../custom_exam_guide/custom_exam_guide_page.dart';
import '../../offline/offline_guide_page.dart';
import '../../purchase/purchase_page.dart';
import 'cubit/main_cubit.dart';

class AdsCard extends StatefulWidget {
  const AdsCard({super.key});

  @override
  State<AdsCard> createState() => _AdsCardState();
}

class _AdsCardState extends State<AdsCard> {
  final MainCubit _mainCubit = getIt.get();
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _onPageChanged(0, null);
  }

  void _onVisibilityChanged(int index, VisibilityInfo info, AdsVariant? variant) {
    if (info.visibleFraction > 0.5) {
      _mainCubit.onAdsShown(index, variant);
    }
  }

  void _onAdsTap(Ads ads, int index, AdsVariant? variant) {
    _mainCubit.logAdsTap(ads, index, variant);

    for (final action in ads.actions) {
      switch (action.intent) {
        case AdsIntent.openUrl:
          launchUrl(Uri.parse(action.data), mode: LaunchMode.externalApplication);
          break;
        case AdsIntent.openAdUrl:
          launchUrl(Uri.parse(action.data), mode: LaunchMode.externalApplication);
          break;
        case AdsIntent.openPurchasePage:
          final productId = action.data;
          final product = getIt.get<IapCubit>().state.products.firstWhereOrNull(
            (p) => p.id == productId,
          );
          if (product != null) {
            Navigator.of(
              context,
            ).pushNamed(PurchasePage.routeName, arguments: PurchasePageArguments(product: product));
          }
          break;
        case AdsIntent.openOfflineGuidePage:
          Navigator.of(context).pushNamed(OfflineGuidePage.routeName);
          break;
        case AdsIntent.openCustomExamGuidePage:
          Navigator.of(context).pushNamed(CustomExamGuidePage.routeName);
          break;
        case AdsIntent.openPage:
          Navigator.of(context).pushNamed(action.data);
          break;
        case AdsIntent.unknown:
          break;
      }
    }
  }

  void _onPageChanged(int index, _) {
    VisibilityDetectorController.instance.notifyNow();
    _currentPageIndex = index;
    setState(() {});
  }

  Widget _buildAds(Ads ads, int index) {
    final AdsVariant? variant = _mainCubit.getSelectedAdsVariant(ads);
    final String imagePath = variant?.imagePath ?? ads.imagePath;

    return VisibilityDetector(
      key: Key('$index $imagePath'),
      onVisibilityChanged: (info) => _onVisibilityChanged(index, info, variant),
      child: GestureDetector(
        onTap: () => _onAdsTap(ads, index, variant),
        child: CachedNetworkImage(
          imageUrl: imagePath,
          fit: BoxFit.cover,
          errorWidget:
              (_, __, ___) =>
                  Center(child: Icon(Icons.image, size: 32, color: Colors.grey.shade300)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainCubit, MainState>(
      buildWhen: (previous, current) => previous.ads != current.ads,
      builder: (context, state) {
        if (state.ads.isEmpty) {
          return const SizedBox.shrink();
        }

        return CustomCard(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  aspectRatio: 2,
                  viewportFraction: 1,
                  autoPlay: state.ads.length > 1,
                  enableInfiniteScroll: state.ads.length > 1,
                  onPageChanged: _onPageChanged,
                ),
                items: [for (final (index, ads) in state.ads.indexed) _buildAds(ads, index)],
              ),
              if (state.ads.length > 1)
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: AnimatedSmoothIndicator(
                    activeIndex: _currentPageIndex,
                    count: state.ads.length,
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
      },
    );
  }
}
