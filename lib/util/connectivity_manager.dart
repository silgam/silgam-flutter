import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../presentation/app/cubit/app_cubit.dart';
import 'injection.dart';

@lazySingleton
class ConnectivityManger {
  late final AppCubit _appCubit = getIt.get();

  StreamSubscription? _connectivityListener;

  String _sessionId = const Uuid().v1();
  StreamSubscription? _realtimeDatabaseListener;
  OnDisconnect? _onDisconnect;
  DatabaseReference? _connectedAtRef;

  Future<void> updateConnectivityListener() async {
    final connectivity = await Connectivity().checkConnectivity();
    _onConnectivityChanged(connectivity);

    _connectivityListener?.cancel();
    _connectivityListener =
        Connectivity().onConnectivityChanged.listen(_onConnectivityChanged);
  }

  void updateRealtimeDatabaseListener({required String? currentUserId}) {
    _realtimeDatabaseListener?.cancel();
    _onDisconnect?.cancel();
    _connectedAtRef?.remove();

    final db = FirebaseDatabase.instance;
    _realtimeDatabaseListener =
        db.ref('.info/connected').onValue.listen((event) {
      final connected = event.snapshot.value == true;
      log(
        'Realtime database connected: $connected',
        name: runtimeType.toString(),
      );
      _appCubit.updateIsOffline(!connected);

      if (connected) {
        final userId = currentUserId ?? 'anonymous';
        _connectedAtRef =
            db.ref('users/$userId/sessions/$_sessionId/connectedAt');
        _onDisconnect = db
            .ref('users/$userId/sessions/$_sessionId/disconnectedAt')
            .onDisconnect();
        _onDisconnect?.set(ServerValue.timestamp);
        _connectedAtRef?.set(ServerValue.timestamp);
      } else {
        _sessionId = const Uuid().v1();
      }
    });
  }

  void _onConnectivityChanged(ConnectivityResult connectivityResult) {
    log('Connectivity changed: $connectivityResult', name: 'AppCubit');
    final isOffline = connectivityResult == ConnectivityResult.none;
    _appCubit.updateIsOffline(isOffline);
  }
}
