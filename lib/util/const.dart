import 'dart:io';

import 'package:flutter/foundation.dart';

const double tabletScreenWidth = 840;
const double maxWidth = 500;
const double maxWidthForTablet = 1000;

const String urlInstagram = "https://silgam.app/instagram";
const String urlSupport = "https://silgam.app/support";
const String urlOpenchat = "https://silgam.app/openchat";
const String urlPrivacy = "https://silgam.app/privacy";
const String urlTerms = "https://silgam.app/terms";
final String urlSilgamApi =
    useFirebaseEmulator
        ? "http://${Platform.isAndroid ? '10.0.2.2' : 'localhost'}:5001/silgam-app/asia-northeast3/api"
        : "https://api.silgam.app";

const isAdmobDisabled = false || kIsWeb;
final String bannerAdId =
    Platform.isAndroid
        ? "ca-app-pub-5293956621132135/7574334463"
        : "ca-app-pub-5293956621132135/7145274842";
final String interstitialAdId =
    Platform.isAndroid
        ? "ca-app-pub-5293956621132135/1155168299"
        : "ca-app-pub-5293956621132135/5094413305";

abstract class PreferenceKey {
  static const useAutoSaveRecords = 'useAutoSaveRecords';
  static const useLapTime = 'useLapTime';
  static const noisePreset = 'noisePreset';
  static const useWhiteNoise = 'whiteNoise';
  static const cacheMe = 'me';
  static const cacheProducts = 'products';
  static const cacheAds = 'ads';
  static const cacheDDays = 'ddays';
  static const isOnboardingFinished = 'isOnboardingFinished';
  static const announcementTypeId = 'announcementTypeId';
  static const selectedAdsVariantIds = 'selectedAdsVariantIds';
}

abstract class ProductId {
  static const free = 'free';
}

const bool useFirebaseEmulator = false;
