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

  List<Ads>? _ads;

  Future<List<Ads>> getAllAds() async {
    if (_ads == null) {
      final snapshot = await _adsRef.get();
      _ads = snapshot.docs.map((document) => document.data()).toList();
    }
    _ads?.shuffle();
    _ads?.sort((a, b) => a.priority - b.priority);
    return _ads ?? [];
  }
}
