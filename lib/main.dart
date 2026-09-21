import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/config/app_config.dart';
import 'core/storage/storage_service.dart';
import 'core/utils/logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize environment configuration
  final config = AppConfig.fromEnvironment();
  AppLogger.enableLogging = config.enableDebugLogs;
  AppLogger.info('Starting ${config.environment.name} environment...');

  // 2. Pre-initialize SharedPreferences for synchronous Riverpod injection
  final sharedPreferences = await SharedPreferences.getInstance();

  // 3. Launch App within ProviderScope with root overrides
  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(config),
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const IraApp(),
    ),
  );
}
