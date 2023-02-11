import 'dart:io';

const double tabletScreenWidth = 840;
const double maxWidth = 500;
const double maxWidthForTablet = 1000;

const String urlInstagram = "https://silgam.app/instagram";
const String urlFacebook = "https://silgam.app/facebook";
const String urlKakaotalk = "https://silgam.app/kakaotalk";
const String urlPrivacy = "https://silgam.app/privacy";
const String urlSilgamApi = "https://api.silgam.app";

final String bannerAdId = Platform.isAndroid
    ? "ca-app-pub-5293956621132135/7574334463"
    : "ca-app-pub-5293956621132135/7145274842";
final String interstitialAdId = Platform.isAndroid
    ? "ca-app-pub-5293956621132135/1155168299"
    : "ca-app-pub-5293956621132135/5094413305";
const bool isAdsEnabled = false;

abstract class PreferenceKey {
  static const showAddRecordPageAfterExamFinished =
      'showAddRecordPageAfterExamFinished';
  static const noisePreset = 'noisePreset';
  static const useWhiteNoise = 'whiteNoise';
  static const cacheMe = 'me';
  static const cacheProducts = 'products';
  static const cacheAds = 'ads';
}
