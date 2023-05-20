import 'dart:io';

const double tabletScreenWidth = 840;
const double maxWidth = 500;
const double maxWidthForTablet = 1000;

const String urlInstagram = "https://silgam.app/instagram";
const String urlSupport = "https://silgam.app/support";
const String urlOpenchat = "https://silgam.app/openchat";
const String urlPrivacy = "https://silgam.app/privacy";
const String urlTerms = "https://silgam.app/terms";
const String urlSilgamApi = "https://api.silgam.app";

final String bannerAdId = Platform.isAndroid
    ? "ca-app-pub-5293956621132135/7574334463"
    : "ca-app-pub-5293956621132135/7145274842";
final String interstitialAdId = Platform.isAndroid
    ? "ca-app-pub-5293956621132135/1155168299"
    : "ca-app-pub-5293956621132135/5094413305";

abstract class PreferenceKey {
  static const showAddRecordPageAfterExamFinished =
      'showAddRecordPageAfterExamFinished';
  static const noisePreset = 'noisePreset';
  static const useWhiteNoise = 'whiteNoise';
  static const cacheMe = 'me';
  static const cacheProducts = 'products';
  static const cacheAds = 'ads';
  static const cacheDDays = 'ddays';
}

abstract class BannerIntent {
  static const openPurchasePage = "openPurchasePage";
}

abstract class ProductId {
  static const free = "free";
  static const silgamPass = "com.seunghyun.silgam.pass2024";
}
