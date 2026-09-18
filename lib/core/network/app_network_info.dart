import 'package:base_kit/base_kit.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// A real implementation of base_kit's NetworkInfoFoundation interface.
/// This is genuine reuse of our own Repos Assemble package: base_kit
/// defines WHAT a "network info" object must expose (just `isAvailable`),
/// and this class provides the actual Android/iOS connectivity check.
///
/// Why bother with the abstract interface instead of just using
/// connectivity_plus directly everywhere? Because the rest of the app
/// only ever depends on NetworkInfoFoundation — if we ever swap the
/// underlying connectivity package, only this one file changes.
class AppNetworkInfo implements NetworkInfoFoundation {
  final _connectivity = Connectivity();

  @override
  bool get isAvailable => _lastKnownState;

  bool _lastKnownState = true;

  /// Call this once at app startup and keep listening — connectivity can
  /// change at any time (e.g. walking out of wifi range).
  Stream<bool> watch() {
    return _connectivity.onConnectivityChanged.map((results) {
      _lastKnownState = !results.contains(ConnectivityResult.none);
      return _lastKnownState;
    });
  }

  Future<bool> checkNow() async {
    final result = await _connectivity.checkConnectivity();
    _lastKnownState = !result.contains(ConnectivityResult.none);
    return _lastKnownState;
  }
}
