import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../routing/app_router.dart';
import '../app/theme/app_theme.dart';
import '../app/providers/app_providers.dart';

/// Root application widget.
class OceanFlowApp extends ConsumerWidget {
  const OceanFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    Animate.restartOnHotReload = true;

    return MaterialApp.router(
      title: 'OceanFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
