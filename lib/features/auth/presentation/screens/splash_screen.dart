import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_theme.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: OceanColors.backgroundDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [OceanColors.primary, OceanColors.teal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: OceanColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: const Icon(
                Icons.waves_rounded,
                size: 60,
                color: Colors.white,
              ),
            )
                .animate()
                .scale(
                  duration: 800.ms,
                  curve: Curves.elasticOut,
                )
                .then()
                .shimmer(duration: 1200.ms),
            const SizedBox(height: 24),
            Text(
              'OCEANFLOW',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 600.ms)
                .slideY(begin: 0.2, end: 0),
            const SizedBox(height: 8),
            Text(
              'Maritime Logistics Platform',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: OceanColors.grey400,
                    letterSpacing: 1,
                  ),
            )
                .animate()
                .fadeIn(delay: 400.ms, duration: 600.ms)
                .slideY(begin: 0.2, end: 0),
            const SizedBox(height: 48),
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(OceanColors.teal),
              ),
            )
                .animate()
                .fadeIn(delay: 600.ms),
          ],
        ),
      ),
    );
  }
}
