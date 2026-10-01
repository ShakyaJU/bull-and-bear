import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A skeleton placeholder shown while data loads, instead of a plain
/// spinner. This is a genuine industry-standard UX pattern — it makes the
/// app feel faster (the eye has something structured to look at) and
/// previews the shape of what's coming, rather than a blank screen with
/// a spinner floating in the middle.
class ShimmerListSkeleton extends StatelessWidget {
  const ShimmerListSkeleton({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: itemCount,
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
