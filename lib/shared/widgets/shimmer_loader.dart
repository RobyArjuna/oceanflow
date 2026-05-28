import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../app/theme/app_theme.dart';

class ShimmerLoader extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  const ShimmerLoader.rectangular({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  const ShimmerLoader.circular({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        borderRadius = const BorderRadius.all(Radius.circular(999));

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF1E2B3C) : const Color(0xFFE2E8F0),
      highlightColor: isDark ? const Color(0xFF2D3748) : const Color(0xFFF1F5F9),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class ShipmentListSkeleton extends StatelessWidget {
  const ShipmentListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const ShimmerLoader.rectangular(width: 140, height: 18),
                    const ShimmerLoader.rectangular(width: 80, height: 20),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.circle, size: 10, color: Colors.grey),
                    const SizedBox(width: 8),
                    const ShimmerLoader.rectangular(width: 120, height: 14),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.circle, size: 10, color: Colors.grey),
                    const SizedBox(width: 8),
                    const ShimmerLoader.rectangular(width: 160, height: 14),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const ShimmerLoader.rectangular(width: 100, height: 14),
                    const ShimmerLoader.rectangular(width: 60, height: 14),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
