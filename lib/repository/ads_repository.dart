import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../model/ads.dart';

@lazySingleton
class AdsRepository {
  final CollectionReference<Ads> _adsRef =
      FirebaseFirestore.instance.collection('ads').withConverter(
            fromFirestore: (snapshot, _) => Ads.fromJson(snapshot.data()!),
            toFirestore: (ads, _) => ads.toJson(),
          );

  Future<List<Ads>> getAllAds() async {
    final snapshot = await _adsRef.get();
    final unsortedAds =
        snapshot.docs.map((document) => document.data()).toList();
    unsortedAds.shuffle();
    unsortedAds.sort((a, b) => a.priority - b.priority);
    return unsortedAds;
  }
}
