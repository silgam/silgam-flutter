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
  DatabaseReference? _connectedAtRef;

  Future<void> updateConnectivityListener() async {
    final connectivityResults = await Connectivity().checkConnectivity();
    _onConnectivityChanged(connectivityResults);

    _connectivityListener?.cancel();
    _connectivityListener =
        Connectivity().onConnectivityChanged.listen(_onConnectivityChanged);
  }

  void updateRealtimeDatabaseListener({required String? currentUserId}) {
    _realtimeDatabaseListener?.cancel();
    _connectedAtRef
      ?..remove()
      ..onDisconnect().cancel();

    _sessionId = const Uuid().v1();
    final db = FirebaseDatabase.instance;
    _realtimeDatabaseListener =
        db.ref('.info/connected').onValue.skip(1).listen((event) {
      final connected = event.snapshot.value == true;
      log(
        'Realtime database connected: $connected',
        name: runtimeType.toString(),
      );
      _appCubit.updateIsOffline(!connected);

      if (connected) {
        final userId = currentUserId ?? 'anonymous';
        _connectedAtRef =
            db.ref('users/$userId/sessions/$_sessionId/connectedAt')
              ..onDisconnect().remove()
              ..set(ServerValue.timestamp);
      } else {
        _sessionId = const Uuid().v1();
      }
    });
  }

  void _onConnectivityChanged(List<ConnectivityResult> connectivityResults) {
    log('Connectivity changed: $connectivityResults', name: 'AppCubit');
    final isOffline = connectivityResults.contains(ConnectivityResult.none);
    _appCubit.updateIsOffline(isOffline);
  }
}
