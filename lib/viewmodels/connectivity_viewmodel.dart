import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityViewModel extends ChangeNotifier {
  ConnectivityViewModel() {
    _init();
  }

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  bool _isOffline = false;

  bool get isOffline => _isOffline;

  Future<void> _init() async {
    await _refreshCurrentStatus();
    _connectivitySub ??= _connectivity.onConnectivityChanged.listen(
      _handleConnectivity,
    );
  }

  Future<void> _refreshCurrentStatus() async {
    final results = await _connectivity.checkConnectivity();
    _handleConnectivity(results);
  }

  void _handleConnectivity(List<ConnectivityResult> results) {
    final hasConnection = results.any(
      (result) => result != ConnectivityResult.none,
    );
    _setOffline(!hasConnection);
  }

  void _setOffline(bool value) {
    if (_isOffline == value) return;
    _isOffline = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    _connectivitySub = null;
    super.dispose();
  }
}
