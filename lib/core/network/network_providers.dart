import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_network_info.dart';

final _networkInfoInstanceProvider = Provider<AppNetworkInfo>((ref) => AppNetworkInfo());

/// A StreamProvider that emits `true`/`false` every time the device's
/// connectivity changes. Any widget can watch this to show an "offline"
/// banner — this is deliberately separate from "is the market API slow
/// or down", which is a completely different problem (see dashboard
/// providers: kIsLive / freshness tracking).
final isOnlineProvider = StreamProvider<bool>((ref) {
  final networkInfo = ref.watch(_networkInfoInstanceProvider);
  return networkInfo.watch();
});
