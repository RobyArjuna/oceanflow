import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'app/flavor/flavor_config.dart';
import 'app/flavor/app_flavor.dart';
import 'services/background_service.dart';

void main() => _bootstrap(AppFlavor.dev);

void _bootstrap(AppFlavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize flavor config
  FlavorConfig.initialize(flavor);

  // Register background tasks
  await BackgroundService.initialize();

  runApp(
    const ProviderScope(
      child: OceanFlowApp(),
    ),
  );
}
