import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/ads.dart';

class AdsRepository {
  AdsRepository._privateConstructor();

  static final AdsRepository _instance = AdsRepository._privateConstructor();

  factory AdsRepository() => _instance;

  final CollectionReference<Ads> _adsRef = FirebaseFirestore.instance.collection('ads').withConverter(
        fromFirestore: (snapshot, _) => Ads.fromJson(snapshot.data()!),
        toFirestore: (ads, _) => ads.toJson(),
      );

  Future<List<Ads>> getAllAds() async {
    final snapshot = await _adsRef.get();
    final unsortedAds = snapshot.docs.map((document) => document.data()).toList();
    unsortedAds.shuffle();
    unsortedAds.sort((a, b) => a.priority - b.priority);
    return unsortedAds;
  }
}
