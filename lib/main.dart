import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  runApp(
    // ProviderScope MUST wrap the whole app for Riverpod to work at all —
    // it's the "storage shelf" that holds every provider's data. Forgetting
    // this is the single most common beginner Riverpod mistake.
    const ProviderScope(
      child: BullAndBearApp(),
    ),
  );
}
